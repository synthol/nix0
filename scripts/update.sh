#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C
shopt -s nullglob
umask 077

readonly UPDATE_SOURCE
readonly UPDATE_VERSION
readonly CONFIG_DIR=/etc/nixos
readonly PERSISTED_CONFIG=/persist/etc/nixos
readonly BACKUP_DIR=/persist/etc/nixos.previous
readonly RELEASE_FILE=/etc/nix0-release
readonly RELEASE_API=https://api.github.com/repos/synthol/nix0/releases/latest
readonly NIXOS_REBUILD=/run/current-system/sw/bin/nixos-rebuild

work_dir=

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

cleanup() {
  local status=$?

  trap - EXIT
  set +e

  if [[ -n ${work_dir:-} &&
    $work_dir == /tmp/nix0-update.* &&
    -d $work_dir ]]; then
    chmod -R u+w -- "$work_dir"
    rm -rf -- "$work_dir"
  fi

  exit "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

valid_version() {
  [[ $1 =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

version_is_newer() {
  local newest

  newest=$(
    printf '%s\n%s\n' "$1" "$2" |
      sort --version-sort |
      tail -n 1
  )

  [[ $1 != "$2" && $newest == "$1" ]]
}

read_release_version() {
  jq --exit-status --raw-output '
    select(
      .id == "nix0"
      and .repository == "synthol/nix0"
    )
    | .version
    | strings
  ' "$RELEASE_FILE"
}

restore_configuration() {
  rsync \
    --archive \
    --delete \
    --exclude='.git/' \
    -- \
    "$BACKUP_DIR/" \
    "$PERSISTED_CONFIG/" &&
    chmod 0755 -- "$PERSISTED_CONFIG"
}

apply_release=false
requested_version=

if (($# > 0)); then
  if [[ $1 == --apply-release && $# == 2 ]]; then
    apply_release=true
    requested_version=$2
  else
    die "Unknown option: $1"
  fi
fi

((EUID == 0)) || die "Run this updater as root"
[[ -t 0 && -t 1 && -t 2 ]] ||
  die "This updater requires an interactive terminal"

[[ -r /etc/os-release ]] || die "Cannot identify the operating system"

# shellcheck disable=SC1091
. /etc/os-release
[[ ${ID:-} == nixos ]] || die "This system is not NixOS"

[[ -x $NIXOS_REBUILD ]] || die "nixos-rebuild is unavailable"
[[ -r $RELEASE_FILE ]] || die "This system is not running nix0"
[[ -d $CONFIG_DIR && -d $PERSISTED_CONFIG ]] ||
  die "The nix0 configuration is unavailable"
[[ $CONFIG_DIR -ef $PERSISTED_CONFIG ]] ||
  die "/etc/nixos is not the expected persistent nix0 configuration"

current_version=$(read_release_version) ||
  die "This system is not running a versioned nix0 release"

valid_version "$current_version" ||
  die "The installed nix0 version is invalid"

exec 9>/run/lock/nix0-update.lock
flock --nonblock 9 || die "Another nix0 update is already running"

config_version=unknown

if [[ -r $CONFIG_DIR/VERSION ]]; then
  config_version=$(<"$CONFIG_DIR/VERSION")

  if ! valid_version "$config_version"; then
    config_version=unknown
  fi
fi

if [[ $apply_release == false ]]; then
  printf 'Checking for nix0 updates...\n'
fi

release_json=$(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 10 \
    --max-time 30 \
    --retry 2 \
    --header "Accept: application/vnd.github+json" \
    --header "X-GitHub-Api-Version: 2026-03-10" \
    "$RELEASE_API"
) || die "Could not check GitHub releases"

latest_version=$(
  jq --exit-status --raw-output '
    select(.draft == false and .prerelease == false)
    | .tag_name
    | strings
  ' <<<"$release_json"
) || die "GitHub did not return a valid release"

valid_version "$latest_version" ||
  die "Latest release tag is not a valid semantic version"

if [[ $current_version == "$latest_version" &&
  $config_version == "$latest_version" ]]; then
  printf 'nix0 %s is already current.\n' "$current_version"
  exit 0
fi

if version_is_newer "$current_version" "$latest_version"; then
  die "The running version is newer than GitHub's latest release"
fi

if [[ $apply_release == false ]]; then
  printf 'Loading the updater from nix0 %s...\n' "$latest_version"

  exec nix run \
    --no-write-lock-file \
    "github:synthol/nix0/${latest_version}#update" \
    -- \
    --apply-release "$latest_version"
fi

[[ $requested_version == "$latest_version" ]] ||
  die "The selected release changed while checking for updates"
[[ $UPDATE_VERSION == "$latest_version" ]] ||
  die "The downloaded updater does not match the latest release"

printf 'Your settings.json values will be preserved.\n'
printf 'All other managed configuration files will be replaced. One backup will be saved to %s.\n\n' "$BACKUP_DIR"

if [[ $current_version == "$latest_version" ]]; then
  printf 'Repair configuration source for nix0 %s? [y/N] (press Enter for no): ' \
    "$latest_version" >&2
else
  printf 'Update nix0 from %s to %s? [y/N] (press Enter for no): ' \
    "$current_version" "$latest_version" >&2
fi

IFS= read -r answer || die "Input ended unexpectedly"

case ${answer,,} in
  y | yes)
    ;;
  *)
    printf 'Update cancelled.\n'
    exit 0
    ;;
esac

work_dir=$(mktemp -d /tmp/nix0-update.XXXXXXXX)
stage_dir=$work_dir/config
merged_settings=$work_dir/settings.json

install -d -m 0755 -- "$stage_dir"
cp -a -- "$UPDATE_SOURCE/." "$stage_dir/"
chmod -R u=rwX,go=rX -- "$stage_dir"

jq --exit-status 'type == "object"' \
  "$stage_dir/settings.json" >/dev/null ||
  die "Release settings.json is invalid"

jq --exit-status 'type == "object"' \
  "$CONFIG_DIR/settings.json" >/dev/null ||
  die "Installed settings.json is invalid"

jq --slurp '.[0] * .[1]' \
  "$stage_dir/settings.json" \
  "$CONFIG_DIR/settings.json" \
  >"$merged_settings"

install -m 0644 -- "$merged_settings" "$stage_dir/settings.json"

[[ -f $CONFIG_DIR/facter.json &&
  ! -L $CONFIG_DIR/facter.json &&
  -r $CONFIG_DIR/facter.json ]] ||
  die "Installed hardware report is unavailable"

install -m 0644 -- \
  "$CONFIG_DIR/facter.json" \
  "$stage_dir/facter.json"

printf '\nValidating nix0 %s...\n\n' "$latest_version"

nix eval \
  --no-update-lock-file \
  --no-write-lock-file \
  --raw \
  "path:${stage_dir}#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" \
  >/dev/null

[[ ! -L $BACKUP_DIR ]] ||
  die "The configuration backup path must not be a symbolic link"

install -d -m 0700 -- "$BACKUP_DIR"

rsync \
  --archive \
  --delete \
  --exclude='.git/' \
  -- \
  "$CONFIG_DIR/" \
  "$BACKUP_DIR/"

chmod 0700 -- "$BACKUP_DIR"

current_specialisation=

for candidate in /nix/var/nix/profiles/system-*-link/specialisation/*; do
  if [[ $candidate -ef /run/current-system ]]; then
    current_specialisation=${candidate##*/}
    break
  fi
done

if [[ $current_version != "$latest_version" ]]; then
  printf '\nBuilding and activating nix0 %s...\n\n' "$latest_version"

  rebuild_arguments=(
    switch
    --flake "path:${stage_dir}#nixos"
    --no-update-lock-file
    --no-write-lock-file
  )

  if [[ -n $current_specialisation ]]; then
    rebuild_arguments+=(--specialisation "$current_specialisation")
  fi

  "$NIXOS_REBUILD" "${rebuild_arguments[@]}"

  activated_version=$(read_release_version) ||
    die "Could not verify the activated release"

  [[ $activated_version == "$latest_version" ]] ||
    die "The activated system did not report the expected version"
fi

if ! rsync \
  --archive \
  --delete-delay \
  --delay-updates \
  --exclude='.git/' \
  -- \
  "$stage_dir/" \
  "$PERSISTED_CONFIG/"; then
  warn "Could not install the new configuration source; restoring the backup"

  restore_configuration ||
    warn "Automatic source restoration also failed"

  die "Configuration source update failed"
fi

installed_version=$(<"$PERSISTED_CONFIG/VERSION")

if [[ $installed_version != "$latest_version" ]]; then
  warn "Installed configuration source has the wrong version; restoring the backup"

  restore_configuration ||
    warn "Automatic source restoration also failed"

  die "Configuration source verification failed"
fi

printf '\nnix0 %s is now current.\n' "$latest_version"
printf 'The previous configuration source is in %s.\n' "$BACKUP_DIR"
printf 'Reboot to use any updated kernel or initrd.\n'

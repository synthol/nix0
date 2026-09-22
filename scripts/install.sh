#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C
shopt -s nullglob
umask 077

readonly INSTALL_SOURCE
readonly INSTALL_CKBCOMP
readonly INSTALL_DISKO
readonly INSTALL_GUM
readonly INSTALL_LOADKEYS
readonly INSTALL_LOCALE_LIST
readonly INSTALL_NIXOS_INSTALL
readonly INSTALL_TZDIR
readonly INSTALL_XKB_RULES
readonly MIN_DISK_BYTES=$((32 * 1024 * 1024 * 1024))
# shellcheck disable=SC2016
readonly YESCRYPT_RE='^\$y\$[./A-Za-z0-9]+\$[./A-Za-z0-9]{0,86}\$[./A-Za-z0-9]{43}$'

disko_started=false
installation_started_at=0
stage_dir=
work_dir=
mount_point=

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

cleanup() {
  local status=$?
  local cleanup_failed=false
  local elapsed_seconds

  trap - EXIT
  set +e

  if [[ ${disko_started:-false} == true &&
    -n ${stage_dir:-} &&
    -d $stage_dir &&
    -n ${mount_point:-} &&
    $mount_point == /mnt/nixos-install.* ]]; then
    "$INSTALL_DISKO" \
      --mode unmount \
      --flake "$stage_dir#nixos" \
      --root-mountpoint "$mount_point" || cleanup_failed=true
  fi

  if [[ -n ${mount_point:-} &&
    $mount_point == /mnt/nixos-install.* &&
    -d $mount_point ]]; then
    if mountpoint -q -- "$mount_point"; then
      umount -R -- "$mount_point" || cleanup_failed=true
    fi
    rmdir -- "$mount_point" || cleanup_failed=true
  fi

  if [[ -n ${work_dir:-} &&
    $work_dir == /tmp/nixos-install.* &&
    -d $work_dir ]]; then
    chmod -R u+w -- "$work_dir" || cleanup_failed=true
    rm -rf -- "$work_dir" || cleanup_failed=true
  fi

  if [[ $cleanup_failed == true ]]; then
    if ((status == 0)) && [[ ${disko_started:-false} == true ]]; then
      warn "Installation completed, but cleanup reported errors"
    else
      warn "Installer cleanup reported errors"
    fi
    ((status != 0)) || status=1
  fi

  if ((status == 0)) && [[ ${disko_started:-false} == true ]]; then
    elapsed_seconds=$((SECONDS - installation_started_at))
    printf '\nInstallation and cleanup succeeded in %dm %ds.\n' \
      "$((elapsed_seconds / 60))" "$((elapsed_seconds % 60))"
    printf 'Keep the NixOS installation media connected until the computer is fully off.\n'
    printf 'Then remove the media and power it on.\n'
    printf '\nAfter booting and logging in, press Super+T (Windows/Meta+T) to open a terminal.\n'
    printf 'Run "nmtui connect" if you need to connect to a network.\n'
    printf '\n'

    if "$INSTALL_GUM" choose \
      --header "" \
      --height 1 \
      --cursor "" \
      --cursor.foreground 230 \
      --cursor.background 212 \
      "Power off now" >/dev/null; then
      if systemctl poweroff; then
        exit "$status"
      fi
      warn "Could not power off automatically"
    fi

    printf '\nRun "sudo systemctl poweroff" when ready.\n'
  fi

  exit "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

(($# == 0)) || die "This installer does not accept arguments"

allow_discards=false

((EUID == 0)) || die "Run this installer as root"
[[ -t 0 && -t 1 && -t 2 ]] ||
  die "This installer requires an interactive terminal"

[[ ! -e $INSTALL_SOURCE/facter.json ]] ||
  die "facter.json must not be committed; it is generated only in the staged copy"

settings_file=$INSTALL_SOURCE/settings.json
[[ -r $settings_file ]] || die "Cannot read settings.json"

read_setting() {
  jq --exit-status --raw-output "$1 | strings" "$settings_file"
}

validate_time_zone() {
  local zone=$1

  [[ $zone =~ ^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+)*$ &&
    -f ${INSTALL_TZDIR}/${zone} ]] ||
    die "Unknown timezone: $zone"
}

validate_locale() {
  local selected_locale=$1

  [[ $selected_locale =~ ^[A-Za-z0-9_][A-Za-z0-9_.@-]*$ ]] ||
    die "Locale contains invalid characters"

  locale_choices |
    awk -v selected="$selected_locale" '
      $0 == selected {
        found = 1
      }

      END {
        exit !found
      }
    ' ||
    die "Unknown locale: $selected_locale"
}

validate_xkb_layout() {
  [[ $1 =~ ^[A-Za-z0-9_-]+(,[A-Za-z0-9_-]+)*$ ]] ||
    die "XKB layout is invalid"
}

validate_xkb_variant() {
  [[ $1 =~ ^[A-Za-z0-9_-]*(,[A-Za-z0-9_-]*)*$ ]] ||
    die "XKB variant is invalid"
}

validate_xkb_selection() {
  local diagnostics

  if ! diagnostics=$(
    "$INSTALL_CKBCOMP" \
      -layout "$xkb_layout" \
      -variant "$xkb_variant" \
      2>&1 >/dev/null
  ); then
    die "XKB layout and variant combination is invalid"
  fi

  [[ $diagnostics != *'WARNING: Can not find'* ]] ||
    die "XKB layout and variant combination is invalid"
}

select_value() {
  local header=$1
  local selected=${2:-}

  awk -v selected="$selected" '
    BEGIN {
      if (selected != "")
        print selected
    }

    $0 != selected
  ' |
    "$INSTALL_GUM" filter \
      --header "$header" \
      --height 15 \
      --limit 1 \
      --placeholder "Type to search"
}

input_value() {
  local header=$1
  local input_error=$2
  shift 2

  if [[ -n $input_error ]]; then
    header="Warning: $input_error"$'\n\n'"$header"
  fi

  "$INSTALL_GUM" input \
    --header "$header" \
    --placeholder "" \
    --char-limit 0 \
    "$@"
}

locale_choices() {
  awk '
    {
      for (field = 1; field <= NF; field++) {
        entry = $field
        sub(/^SUPPORTED-LOCALES=/, "", entry)
        sub(/\\$/, "", entry)

        delete parts
        split(entry, parts, "/")

        if (parts[2] == "UTF-8")
          print parts[1]
      }
    }
  ' "$INSTALL_LOCALE_LIST"
}

xkb_layout_choices() {
  awk '
    $0 == "! layout" {
      layouts = 1
      next
    }

    layouts && /^!/ {
      exit
    }

    layouts && NF >= 2 && $1 != "custom" {
      code = $1
      sub(/^[[:space:]]*[^[:space:]]+[[:space:]]+/, "")
      printf "%-12s %s\n", code, $0
    }
  ' "$INSTALL_XKB_RULES"
}

time_zone_choices() {
  printf 'UTC\n'

  awk '
    !/^#/ && NF >= 3 {
      print $3
    }
  ' "$INSTALL_TZDIR/zone1970.tab"
}

prepare_keyboard() {
  local console
  local keyboard_label

  console=${SUDO_TTY:-$(tty 2>/dev/null)} ||
    die "Cannot determine the installation terminal"

  if [[ $console =~ ^/dev/tty[1-9][0-9]*$ ]]; then
    "$INSTALL_CKBCOMP" \
      -layout "$xkb_layout" \
      -variant "$xkb_variant" |
      "$INSTALL_LOADKEYS" --quiet --console "$console" ||
      die "Could not apply the selected keyboard layout"
  else
    keyboard_label="$xkb_layout_name keyboard layout"

    if [[ -n $xkb_variant ]]; then
      keyboard_label+=" (variant: $xkb_variant)"
    fi

    "$INSTALL_GUM" confirm --default=false \
      "Does the live desktop use the $keyboard_label?" ||
      die "Keyboard layout confirmation was cancelled"
  fi
}

default_username=$(read_setting '.username')
default_host_name=$(read_setting '.hostName')
default_time_zone=$(read_setting '.timeZone')
default_locale=$(read_setting '.locale')
default_xkb_layout=$(read_setting '.xkbLayout')

jq --exit-status '
  (.battery | type == "object")
  and (.git | type == "object")
  and (.gpuPassthrough | type == "object")
  and (.hardwareProfiles | type == "object")
' "$settings_file" >/dev/null ||
  die "settings.json battery, git, gpuPassthrough, and hardwareProfiles must be objects"

xkb_variant=$(read_setting '.xkbVariant')

[[ $(uname -m) == x86_64 ]] ||
  die "This installer supports only x86_64 machines"

efivars=/sys/firmware/efi/efivars
[[ -d $efivars ]] || die "The machine was not booted in UEFI mode"

efi_fstype=$(findmnt --noheadings --raw --output FSTYPE --target "$efivars")
efi_options=$(findmnt --noheadings --raw --output OPTIONS --target "$efivars")

[[ $efi_fstype == efivarfs ]] || die "efivarfs is not mounted"
[[ ,$efi_options, == *,rw,* && -w $efivars ]] ||
  die "efivarfs is not writable"

secure_boot_vars=("$efivars"/SecureBoot-*)
((${#secure_boot_vars[@]} == 1)) ||
  die "Cannot determine Secure Boot state"

secure_boot_state=$(
  od --address-radix=n --format=u1 --skip-bytes=4 --read-bytes=1 \
    "${secure_boot_vars[0]}" |
    tr -d '[:space:]'
)

case $secure_boot_state in
  0)
    ;;
  1)
    die "Secure Boot must be disabled"
    ;;
  *)
    die "Cannot determine Secure Boot state"
    ;;
esac

lsblk_value() {
  local field=$1
  local device=$2
  shift 2

  lsblk "$@" --nodeps --noheadings --raw --output "$field" "$device" |
    tr -d '[:space:]'
}

disk_choices() {
  local reference
  local canonical
  local disk_type
  local disk_size
  local disk_model
  local -A seen=()

  for reference in /dev/disk/by-id/*; do
    [[ -L $reference && $reference != *-part[0-9]* ]] || continue

    canonical=$(readlink -f -- "$reference") || continue
    [[ -b $canonical ]] || continue

    disk_type=$(lsblk_value TYPE "$canonical") || continue
    [[ $disk_type == disk ]] || continue
    [[ -z ${seen[$canonical]+x} ]] || continue

    disk_size=$(lsblk_value SIZE "$canonical") || continue
    disk_model=$(
      lsblk --nodeps --noheadings --raw --output MODEL "$canonical"
    ) || continue

    disk_model=${disk_model//$'\t'/ }
    disk_model=${disk_model//$'\n'/ }
    disk_model=${disk_model//$'\r'/ }
    disk_model=${disk_model#"${disk_model%%[![:space:]]*}"}
    disk_model=${disk_model%"${disk_model##*[![:space:]]}"}
    [[ -n $disk_model ]] || disk_model=unknown

    seen["$canonical"]=true
    printf '%-8s\t%-24s\t%s\n' \
      "$disk_size" "$disk_model" "$reference"
  done
}

resolve_target_disk() {
  local reference=$1
  local canonical
  local disk_type
  local read_only

  [[ $reference =~ ^/dev/disk/by-id/[^/]+$ ]] ||
    die "Use a disk path under /dev/disk/by-id"
  [[ $reference != *-part[0-9]* ]] ||
    die "Select a whole disk, not a partition"
  [[ -L $reference ]] || die "Target is not a /dev/disk/by-id symlink"

  canonical=$(readlink -f -- "$reference") ||
    die "Cannot resolve target disk"
  [[ -b $canonical ]] || die "Target is not a block device"

  disk_type=$(lsblk_value TYPE "$canonical")
  read_only=$(lsblk_value RO "$canonical")

  [[ $disk_type == disk ]] || die "Target is not a whole disk"
  [[ $read_only == 0 && -w $canonical ]] ||
    die "Target disk is not writable"

  printf '%s\n' "$canonical"
}

check_disk_safety() {
  local disk=$1
  local disk_size
  local mountpoints
  local live_path
  local source
  local source_device
  local node
  local swap_device
  local block_name
  local holder_paths=()
  local nodes=()
  local block_names=()
  local swaps=()

  [[ ! -e /dev/mapper/system && ! -L /dev/mapper/system ]] ||
    die "/dev/mapper/system already exists; reboot into fresh installation media before retrying"

  mapfile -t nodes < <(
    lsblk --raw --noheadings --paths --output PATH "$disk"
  )
  ((${#nodes[@]} > 0)) || die "Cannot inspect target disk"

  disk_size=$(lsblk_value SIZE "$disk" --bytes)
  [[ $disk_size =~ ^[0-9]+$ ]] || die "Cannot determine target size"
  ((disk_size >= MIN_DISK_BYTES)) ||
    die "Target disk is smaller than 32 GiB"

  mountpoints=$(
    lsblk --raw --noheadings --output MOUNTPOINTS "$disk"
  )
  [[ -z ${mountpoints//[[:space:]]/} ]] ||
    die "Target disk or one of its children is mounted"

  for live_path in / /nix/store /iso; do
    [[ -e $live_path ]] || continue

    source=$(
      findmnt --noheadings --raw --output SOURCE --target "$live_path" \
        2>/dev/null || :
    )
    source=${source%%\[*}

    [[ -b $source ]] || continue
    source_device=$(readlink -f -- "$source") || continue

    for node in "${nodes[@]}"; do
      if [[ $(readlink -f -- "$node") == "$source_device" ]]; then
        die "Target contains the installer or running-system device"
      fi
    done
  done

  mapfile -t swaps < <(
    swapon --noheadings --raw --output NAME 2>/dev/null || :
  )

  for swap_device in "${swaps[@]}"; do
    [[ -b $swap_device ]] || continue
    swap_device=$(readlink -f -- "$swap_device") || continue

    for node in "${nodes[@]}"; do
      if [[ $(readlink -f -- "$node") == "$swap_device" ]]; then
        die "Target disk has active swap"
      fi
    done
  done

  mapfile -t block_names < <(
    lsblk --raw --noheadings --output KNAME "$disk"
  )

  for block_name in "${block_names[@]}"; do
    holder_paths=(/sys/class/block/"$block_name"/holders/*)

    if ((${#holder_paths[@]} > 0)); then
      die "Target disk has active holders: ${holder_paths[*]}"
    fi
  done
}

disk_identity() {
  lsblk \
    --bytes \
    --json \
    --nodeps \
    --output PATH,KNAME,MAJ:MIN,SIZE,RO,TYPE,MODEL,SERIAL,WWN,TRAN \
    "$1" |
    jq --compact-output '.blockdevices[0]'
}

show_disk_identity() {
  local reference=$1
  local identity=$2

  jq --raw-output --arg reference "$reference" '
    "  by-id:       \($reference)",
    "  device:      \(.path)",
    "  kernel name: \(.kname)",
    "  major:minor: \(."maj:min")",
    "  size:        \(.size) bytes",
    "  model:       \(.model // "unknown")",
    "  serial:      \(.serial // "unknown")",
    "  WWN:         \(.wwn // "unknown")",
    "  transport:   \(.tran // "unknown")"
  ' <<<"$identity"
}

validate_yescrypt() {
  [[ $1 =~ $YESCRYPT_RE ]] ||
    die "Password hash is not a valid single-line yescrypt hash"
}

default_xkb_choice=$(
  xkb_layout_choices |
    awk -v layout="$default_xkb_layout" '
      $1 == layout {
        print
      }
    '
)

[[ -n $default_xkb_choice ]] ||
  die "Default XKB layout is not in the pinned layout list"

xkb_choice=$(
  xkb_layout_choices |
    select_value \
      "Select keyboard layout" \
      "$default_xkb_choice"
) || die "Keyboard layout selection was cancelled"

read -r xkb_layout xkb_layout_name <<<"$xkb_choice"
unset default_xkb_choice xkb_choice

validate_xkb_layout "$xkb_layout"
validate_xkb_variant "$xkb_variant"
validate_xkb_selection
prepare_keyboard

locale=$(
  {
    printf '%s\n' "$default_locale"
    locale_choices
  } |
    sort -u |
    select_value \
      "Select locale" \
      "$default_locale"
) || die "Locale selection was cancelled"

validate_locale "$locale"

time_zone=$(
  {
    printf '%s\n' "$default_time_zone"
    time_zone_choices
  } |
    sort -u |
    select_value \
      "Select timezone" \
      "$default_time_zone"
) || die "Timezone selection was cancelled"

validate_time_zone "$time_zone"

mapfile -t available_disks < <(disk_choices)
((${#available_disks[@]} > 0)) ||
  die "No whole disks with /dev/disk/by-id identifiers were found"

disk_choice=$(
  printf '%s\n' "${available_disks[@]}" |
    select_value "Select target disk"
) || die "Disk selection was cancelled"

disk_reference=${disk_choice##*$'\t'}
unset available_disks disk_choice

target_disk=$(resolve_target_disk "$disk_reference")
check_disk_safety "$target_disk"

trim_answer=$(
  "$INSTALL_GUM" choose \
    --header $'Discard/TRIM lets storage reclaim unused blocks.\nAllowing it through LUKS reveals allocation patterns.\n\nAllow discard/TRIM requests through LUKS?' \
    --height 2 \
    --selected "No" \
    "Yes" "No"
) || die "Discard/TRIM selection was cancelled"

if [[ $trim_answer == Yes ]]; then
  allow_discards=true
fi

unset trim_answer

initial_identity=$(disk_identity "$target_disk")
[[ $initial_identity != null ]] || die "Cannot read target disk identity"

input_error=
while :; do
  username=$(input_value "Username" "$input_error" --value "$default_username") ||
    die "Username input was cancelled"
  username=${username:-$default_username}

  if [[ ! $username =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then
    input_error=$'Username must start with a lowercase letter or underscore.\nUse lowercase letters, digits, underscores, or hyphens; maximum 31 characters.'
    continue
  fi

  case $username in
    root)
      input_error="Reserved username: $username"
      continue
      ;;
  esac

  break
done

input_error=
while :; do
  host_name=$(input_value "Hostname" "$input_error" --value "$default_host_name") ||
    die "Hostname input was cancelled"
  host_name=${host_name:-$default_host_name}

  if [[ $host_name =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
    break
  fi

  input_error=$'Hostname must contain 1-63 lowercase letters, digits, or hyphens.\nIt cannot start or end with a hyphen.'
done

input_error=
while :; do
  password=$(input_value "Password for $username" "$input_error" --password) ||
    die "Password input was cancelled"

  password_confirmation=$(input_value "Confirm password" "" --password) ||
    die "Password confirmation was cancelled"

  if [[ -z $password ]]; then
    input_error="Password must not be empty"
    unset password password_confirmation
    continue
  fi

  if [[ $password != "$password_confirmation" ]]; then
    input_error="Passwords do not match"
    unset password password_confirmation
    continue
  fi

  password_hash=$(
    printf '%s\n' "$password" |
      mkpasswd --method=yescrypt --stdin
  )

  unset password password_confirmation
  validate_yescrypt "$password_hash"
  break
done

unset input_error

[[ ! -L /mnt ]] || die "/mnt must not be a symbolic link"
install -d -m 0755 -- /mnt

mount_point=$(mktemp -d /mnt/nixos-install.XXXXXXXX)
chmod 0755 -- "$mount_point"

work_dir=$(mktemp -d /tmp/nixos-install.XXXXXXXX)
stage_dir=$work_dir/config
passwords_dir=$work_dir/passwords

install -d -m 0755 -- "$stage_dir"
cp -a -- "$INSTALL_SOURCE/." "$stage_dir/"
chmod -R u=rwX,go=rX -- "$stage_dir"

jq \
  --arg installDisk "$disk_reference" \
  --argjson allowDiscards "$allow_discards" \
  --arg username "$username" \
  --arg hostName "$host_name" \
  --arg timeZone "$time_zone" \
  --arg locale "$locale" \
  --arg xkbLayout "$xkb_layout" \
  '
    . + {
      installDisk: $installDisk,
      allowDiscards: $allowDiscards,
      username: $username,
      hostName: $hostName,
      timeZone: $timeZone,
      locale: $locale,
      xkbLayout: $xkbLayout
    }
  ' \
  "$settings_file" >"$stage_dir/settings.json"

nixos-facter --output "$stage_dir/facter.json"
chmod 0644 -- "$stage_dir/facter.json"

install -d -m 0700 -- "$passwords_dir"
printf '%s\n' "$password_hash" >"$passwords_dir/$username"
chmod 0600 -- "$passwords_dir/$username"
unset password_hash

printf '\nValidating the complete NixOS configuration...\n'

nix \
  --extra-experimental-features "nix-command flakes" \
  eval \
  --no-update-lock-file \
  --no-write-lock-file \
  --raw \
  "$stage_dir#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" \
  >/dev/null

printf '\nThe selected disk is:\n\n'
show_disk_identity "$disk_reference" "$initial_identity"
printf '\nAll existing data on this disk will be erased.\n'

confirmation=$(input_value "Type ERASE to erase the disk shown above" "") ||
  die "Disk erasure confirmation was cancelled"

[[ $confirmation == ERASE ]] ||
  die "Confirmation did not match; nothing was erased"

installation_started_at=$SECONDS

rechecked_disk=$(resolve_target_disk "$disk_reference")
[[ $rechecked_disk == "$target_disk" ]] ||
  die "The /dev/disk/by-id link now identifies a different disk"

rechecked_identity=$(disk_identity "$target_disk")
[[ $rechecked_identity == "$initial_identity" ]] ||
  die "Target disk identity changed after confirmation"

check_disk_safety "$target_disk"

printf '\nDisk identity and safety checks passed.\n'
printf 'Disko will now request a separate LUKS passphrase.\n'
printf 'Starting pinned official Disko...\n\n'

disko_started=true

(
  umask 022
  "$INSTALL_DISKO" \
    --mode destroy,format,mount \
    --flake "$stage_dir#nixos" \
    --root-mountpoint "$mount_point" \
    --yes-wipe-all-disks
)

mountpoint -q -- "$mount_point/nix" ||
  die "Disko did not mount the target Nix store at $mount_point/nix"
mountpoint -q -- "$mount_point/persist" ||
  die "Disko did not mount target persistence at $mount_point/persist"

install -d -m 0755 -- "$mount_point/persist/etc/nixos"
cp -a -- "$stage_dir/." "$mount_point/persist/etc/nixos/"

install -d -m 0700 -- "$mount_point/persist/passwords"
install -m 0600 -- \
  "$passwords_dir/$username" \
  "$mount_point/persist/passwords/$username"

printf '\nDisko completed. Building and installing NixOS in the target store...\n\n'

(
  umask 022
  "$INSTALL_NIXOS_INSTALL" \
    --root "$mount_point" \
    --flake "$stage_dir#nixos" \
    --no-update-lock-file \
    --no-write-lock-file \
    --no-channel-copy \
    --no-root-password
)

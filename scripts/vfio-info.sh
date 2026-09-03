#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C
shopt -s nullglob

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

for required_command in grep lspci readlink sort; do
  command -v "$required_command" >/dev/null ||
    die "$required_command is required"
done

pci_description() {
  local line

  line=$(lspci -Dnn -s "$1")
  printf '%s' "${line#* }"
}

pci_driver() {
  local device_path=$1
  local driver_path

  if [[ -L $device_path/driver ]]; then
    driver_path=$(readlink -f -- "$device_path/driver")
    printf '%s' "${driver_path##*/}"
  else
    printf 'unbound'
  fi
}

print_json_array() {
  local separator=
  local value

  printf '['

  for value in "$@"; do
    printf '%s"%s"' "$separator" "$value"
    separator=', '
  done

  printf ']'
}

printf 'Virtualisation\n'

if grep -m1 -qw vmx /proc/cpuinfo; then
  printf '  CPU:   Intel VT-x (VMX) available\n'
elif grep -m1 -qw svm /proc/cpuinfo; then
  printf '  CPU:   AMD-V (SVM) available\n'
else
  printf '  CPU:   unavailable; check firmware settings\n'
fi

if [[ -c /dev/kvm ]]; then
  if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    printf '  KVM:   available to current user\n'
  else
    printf '  KVM:   available but inaccessible to current user\n'
  fi
else
  printf '  KVM:   unavailable\n'
fi

iommu_groups=(/sys/kernel/iommu_groups/[0-9]*)

if ((${#iommu_groups[@]} > 0)); then
  printf '  IOMMU: active (%d groups)\n' "${#iommu_groups[@]}"
else
  printf '  IOMMU: inactive; check VT-d/AMD-Vi\n'
fi

mapfile -t gpu_addresses < <(
  for device_path in /sys/bus/pci/devices/*; do
    [[ -r $device_path/class ]] || continue

    class=$(<"$device_path/class")
    class=${class,,}

    if [[ $class == 0x03* ]]; then
      printf '%s\n' "${device_path##*/}"
    fi
  done |
    sort -V
)

printf '\nGraphics\n'

if ((${#gpu_addresses[@]} == 0)); then
  printf '  None detected\n'
  exit 0
fi

declare -A shown_groups=()
device_separator=

for address in "${gpu_addresses[@]}"; do
  device_path=/sys/bus/pci/devices/$address
  driver=$(pci_driver "$device_path")
  description=$(pci_description "$address")
  boot_vga=unknown

  if [[ -r $device_path/boot_vga ]]; then
    if [[ $(<"$device_path/boot_vga") == 1 ]]; then
      boot_vga=yes
    else
      boot_vga=no
    fi
  fi

  printf '%s  %s  %s\n' "$device_separator" "$address" "$description"
  device_separator=$'\n'

  if [[ ! -L $device_path/iommu_group ]]; then
    printf '    driver=%s  boot=%s  group=unavailable\n' \
      "$driver" "$boot_vga"
    continue
  fi

  group_path=$(readlink -f -- "$device_path/iommu_group")
  group_id=${group_path##*/}

  printf '    driver=%s  boot=%s  group=%s\n' \
    "$driver" "$boot_vga" "$group_id"

  if [[ -n ${shown_groups[$group_id]+x} ]]; then
    continue
  fi

  shown_groups["$group_id"]=true

  mapfile -t group_members < <(
    for member_path in "$group_path"/devices/*; do
      printf '%s\n' "${member_path##*/}"
    done |
      sort -V
  )

  passthrough_addresses=()
  bridge_conflict=false

  printf '    members:\n'

  for member_address in "${group_members[@]}"; do
    member_path=/sys/bus/pci/devices/$member_address
    member_class=$(<"$member_path/class")
    member_class=${member_class,,}
    member_driver=$(pci_driver "$member_path")
    member_description=$(pci_description "$member_address")

    if [[ $member_class == 0x0604* ]]; then
      member_kind=bridge

      if [[ $member_driver != unbound ]]; then
        bridge_conflict=true
      fi
    else
      member_kind=endpoint
      passthrough_addresses+=("$member_address")
    fi

    printf '      %s  %s  driver=%s  %s\n' \
      "$member_address" "$member_kind" "$member_driver" "$member_description"
  done

  printf '    gpuPassthrough.pciAddresses: '
  print_json_array "${passthrough_addresses[@]}"
  printf '\n'

  if [[ $bridge_conflict == true ]]; then
    printf '    Warning: group contains a host-bound PCI bridge; passthrough validation will fail.\n'
  fi
done

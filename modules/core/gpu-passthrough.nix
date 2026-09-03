{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let
  cfg = settings.gpuPassthrough or { };
  passthroughEnabled = cfg.enable or false;

  lookingGlass = cfg.lookingGlass or { };
  lookingGlassEnabled = lookingGlass.enable or false;
  lookingGlassMemoryMiB = lookingGlass.memoryMiB or 64;

  report = config.hardware.facter.report;

  pciAddresses = lib.unique (map lib.strings.toLower (cfg.pciAddresses or [ ]));
  escapedPciAddresses = lib.concatMapStringsSep " " lib.escapeShellArg pciAddresses;

  allHardwareDevices = lib.concatLists (
    lib.filter builtins.isList (lib.attrValues (report.hardware or { }))
  );

  pciDevices = lib.filter (
    device:
    (device.bus_type.name or null) == "PCI"
    && (device.vendor.hex or null) != null
    && (device.device.hex or null) != null
    && (device.sysfs_bus_id or null) != null
  ) allHardwareDevices;

  pciAddressOf = device: lib.strings.toLower (device.sysfs_bus_id or "");
  pciIdOf = device: lib.strings.toLower "${device.vendor.hex}:${device.device.hex}";

  isPciBridge =
    device:
    (lib.strings.toLower (device.base_class.hex or "")) == "0006"
    && (lib.strings.toLower (device.sub_class.hex or "")) == "0004";
  isNvidia = device: lib.strings.toLower (device.vendor.hex or "") == "10de";

  selectedDevices = lib.filter (device: lib.elem (pciAddressOf device) pciAddresses) pciDevices;

  selectedGraphics = lib.filter (
    device: lib.elem "graphics_card" (device.class_list or [ ])
  ) selectedDevices;

  remainingGraphics = lib.filter (device: !(lib.elem (pciAddressOf device) pciAddresses)) (
    report.hardware.graphics_card or [ ]
  );

  selectedBridges = lib.filter isPciBridge selectedDevices;

  invalidPciAddresses = lib.filter (
    address: builtins.match "[0-9a-f]+:[0-9a-f]{2}:[01][0-9a-f]\\.[0-7]" address == null
  ) pciAddresses;

  missingPciAddresses = lib.filter (
    address: !(lib.any (device: pciAddressOf device == address) pciDevices)
  ) pciAddresses;

  verifyPciDevice =
    device:
    let
      address = pciAddressOf device;
      expectedId = pciIdOf device;
      vendor = lib.strings.toLower device.vendor.hex;
      product = lib.strings.toLower device.device.hex;
    in
    ''
      if [[ ! -d /sys/bus/pci/devices/${address} ]]; then
        printf 'Configured PCI device %s is missing.\n' '${address}' >&2
        exit 1
      fi

      if [[ "$(< /sys/bus/pci/devices/${address}/vendor)" != "0x${vendor}" ||
            "$(< /sys/bus/pci/devices/${address}/device)" != "0x${product}" ]]; then
        printf 'PCI device %s no longer matches Facter (%s).\n' \
          '${address}' '${expectedId}' >&2
        exit 1
      fi
    '';

  validateIommuGroups = ''
    is_selected_pci_address() {
      local candidate_address="$1"
      local configured_address

      for configured_address in ${escapedPciAddresses}; do
        if [[ "$candidate_address" == "$configured_address" ]]; then
          return 0
        fi
      done

      return 1
    }

    for selected_address in ${escapedPciAddresses}; do
      device_path="/sys/bus/pci/devices/$selected_address"
      group_link="$device_path/iommu_group"

      if [[ ! -L "$group_link" ]]; then
        printf 'Selected PCI device %s has no IOMMU group.\n' \
          "$selected_address" >&2
        exit 1
      fi

      group_path=$(readlink -f -- "$group_link")
      group_id=$(basename -- "$group_path")
      group_invalid=false

      for member_path in "$group_path"/devices/*; do
        member_address=$(basename -- "$member_path")

        if is_selected_pci_address "$member_address"; then
          continue
        fi

        if [[ ! -r "$member_path/class" ]]; then
          printf 'Cannot determine the PCI class of %s.\n' \
            "$member_address" >&2
          exit 1
        fi

        member_class=$(< "$member_path/class")

        if [[ "$member_class" == 0x0604* && ! -L "$member_path/driver" ]]; then
          continue
        fi

        member_driver=unbound

        if [[ -L "$member_path/driver" ]]; then
          member_driver=$(
            basename -- "$(readlink -f -- "$member_path/driver")"
          )
        fi

        printf 'IOMMU group %s has an unselected member: %s (class %s, driver %s).\n' \
          "$group_id" "$member_address" "$member_class" "$member_driver" >&2
        group_invalid=true
      done

      if [[ "$group_invalid" == true ]]; then
        printf '%s\n' \
          'Use another IOMMU group or deliberately include every non-bridge endpoint.' >&2
        printf '%s\n' \
          'An unselected PCI bridge is allowed only when it has no host driver.' >&2
        exit 1
      fi
    done
  '';

  setPciDriverOverride =
    device:
    let
      address = pciAddressOf device;
    in
    ''
      printf '%s\n' vfio-pci \
        > /sys/bus/pci/devices/${address}/driver_override
    '';

  bindPciDevice =
    device:
    let
      address = pciAddressOf device;
    in
    ''
      if [[ ! -L /sys/bus/pci/devices/${address}/driver ]]; then
        printf '%s\n' '${address}' \
          > /sys/bus/pci/drivers/vfio-pci/bind
      fi

      if ! [[ /sys/bus/pci/devices/${address}/driver \
              -ef /sys/bus/pci/drivers/vfio-pci ]]; then
        printf 'vfio-pci did not claim PCI device %s.\n' \
          '${address}' >&2
        exit 1
      fi
    '';

  vfioBindScript = ''
    set -eu

    ${lib.concatMapStringsSep "\n" verifyPciDevice selectedDevices}
    ${validateIommuGroups}

    ${lib.concatMapStringsSep "\n" setPciDriverOverride selectedDevices}

    modprobe vfio_pci

    ${lib.concatMapStringsSep "\n" bindPciDevice selectedDevices}
  '';

  vfioBindTargets = [
    "systemd-modules-load.service"
    "systemd-udev-trigger.service"
  ];

  cpuFeatures = lib.unique (lib.concatMap (cpu: cpu.features or [ ]) (report.hardware.cpu or [ ]));

  iommuKernelParameter =
    if lib.elem "vmx" cpuFeatures then
      "intel_iommu=on"
    else if lib.elem "svm" cpuFeatures then
      "amd_iommu=on"
    else
      null;

  selectedNvidia = lib.any isNvidia selectedGraphics;
  remainingNvidia = lib.any isNvidia remainingGraphics;

  lookingGlassMemorySizes = [
    32
    64
    128
    256
    512
    1024
  ];
in
{
  assertions = [
    {
      assertion = !lookingGlassEnabled || passthroughEnabled;
      message = "gpuPassthrough.lookingGlass.enable requires gpuPassthrough.enable.";
    }
  ]
  ++ lib.optionals passthroughEnabled [
    {
      assertion = report != { };
      message = "GPU passthrough requires a generated Facter report.";
    }
    {
      assertion = pciAddresses != [ ];
      message = "gpuPassthrough.pciAddresses must not be empty when GPU passthrough is enabled.";
    }
    {
      assertion = invalidPciAddresses == [ ];
      message = ''
        gpuPassthrough.pciAddresses entries must use domain:bus:device.function form.
        Example: "0000:01:00.0".
        Invalid values: ${lib.concatStringsSep ", " invalidPciAddresses}
      '';
    }
    {
      assertion = missingPciAddresses == [ ];
      message = ''
        Facter did not detect these gpuPassthrough.pciAddresses entries:
        ${lib.concatStringsSep ", " missingPciAddresses}
      '';
    }
    {
      assertion = selectedGraphics != [ ];
      message = "gpuPassthrough.pciAddresses must select at least one graphics device.";
    }
    {
      assertion = selectedBridges == [ ];
      message = ''
        gpuPassthrough.pciAddresses must not include PCI bridges.
        Remove: ${lib.concatStringsSep ", " (map pciAddressOf selectedBridges)}

        Driverless PCI bridges in the selected IOMMU group are handled automatically.
      '';
    }
    {
      assertion = iommuKernelParameter != null;
      message = "Facter did not detect Intel VMX or AMD SVM CPU support.";
    }
    {
      assertion = config.virtualisation.libvirtd.enable;
      message = "GPU passthrough requires virtualisation.libvirtd.enable.";
    }
    {
      assertion = !lookingGlassEnabled || lib.elem lookingGlassMemoryMiB lookingGlassMemorySizes;
      message = ''
        gpuPassthrough.lookingGlass.memoryMiB must use a supported power-of-two size:
        ${lib.concatStringsSep ", " (map toString lookingGlassMemorySizes)}
      '';
    }
  ];

  specialisation = lib.mkIf passthroughEnabled {
    gpu-passthrough.configuration =
      { config, ... }:
      lib.mkMerge [
        {
          boot = {
            kernelParams = lib.optional (iommuKernelParameter != null) iommuKernelParameter;

            initrd = {
              availableKernelModules = [ "vfio_pci" ];

              systemd.services.vfio-pci-bind = {
                description = "Bind selected PCI devices to vfio-pci";

                requiredBy = vfioBindTargets;
                before = vfioBindTargets;

                unitConfig.DefaultDependencies = false;
                serviceConfig.Type = "oneshot";
                script = vfioBindScript;
              };
            };
          };
        }

        (lib.mkIf (selectedNvidia && !remainingNvidia) {
          services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

          hardware.nvidia = {
            powerManagement = {
              enable = lib.mkForce false;
              finegrained = lib.mkForce false;
            };

            prime.offload = {
              enable = lib.mkForce false;
              enableOffloadCmd = lib.mkForce false;
            };
          };
        })

        (lib.mkIf lookingGlassEnabled {
          boot = {
            extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
            kernelModules = [ "kvmfr" ];
            extraModprobeConfig = "options kvmfr static_size_mb=${toString lookingGlassMemoryMiB}";
          };

          environment.systemPackages = [ pkgs.looking-glass-client ];

          services.udev.extraRules = ''
            SUBSYSTEM=="kvmfr", OWNER="qemu-libvirtd", GROUP="libvirtd", MODE="0660"
          '';

          virtualisation.libvirtd.qemu.verbatimConfig = ''
            namespaces = []

            cgroup_device_acl = [
              "/dev/null",
              "/dev/full",
              "/dev/zero",
              "/dev/random",
              "/dev/urandom",
              "/dev/ptmx",
              "/dev/userfaultfd",
              "/dev/kvmfr0"
            ]
          '';
        })
      ];
  };
}

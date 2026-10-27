{
  config,
  lib,
  settings,
  ...
}:
let
  cfg = settings.battery or { };
  genericCfg = cfg.generic or { };
  acerCfg = cfg.acerWmi or { };
  kernel = config.boot.kernelPackages.kernel;
in
{
  systemd.tmpfiles.rules = lib.optionals (genericCfg.enable or false) [
    "w- /sys/class/power_supply/*/charge_control_start_threshold - - - - 75"
    "w- /sys/class/power_supply/*/charge_control_end_threshold - - - - 80"
  ];

  boot = lib.mkIf (acerCfg.enable or false) {
    extraModulePackages = [
      (config.boot.kernelPackages.acer-wmi-battery.overrideAttrs (old: {
        makeFlags = old.makeFlags ++ [
          "INSTALL_MOD_PATH=${placeholder "out"}"
          "INSTALL_MOD_DIR=kernel/drivers/platform/x86"
          "INSTALL_MOD_STRIP=1"
          "DEPMOD=true"
        ];
        installFlags = [
          "-C"
          "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "M=$(PWD)"
        ];
        installTargets = [ "modules_install" ];
        installPhase = null;
      }))
    ];
    kernelModules = [ "acer-wmi-battery" ];
    extraModprobeConfig = "options acer-wmi-battery enable_health_mode=1";
  };
}

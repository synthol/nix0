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
in
{
  systemd.tmpfiles.rules = lib.optionals (genericCfg.enable or false) [
    "w- /sys/class/power_supply/*/charge_control_start_threshold - - - - 75"
    "w- /sys/class/power_supply/*/charge_control_end_threshold - - - - 80"
  ];

  boot = lib.mkIf (acerCfg.enable or false) {
    extraModulePackages = [ config.boot.kernelPackages.acer-wmi-battery ];
    kernelModules = [ "acer-wmi-battery" ];
    extraModprobeConfig = "options acer-wmi-battery enable_health_mode=1";
  };
}

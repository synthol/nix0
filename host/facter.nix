{ config, lib, ... }:
{
  options.hardware.facter.detected.boot.graphics.kernelModules = lib.mkOption {
    apply =
      modules:
      if config.hardware.nvidia.enabled then
        modules
      else
        lib.filter (module: !(lib.hasPrefix "nvidia" module)) modules;
  };

  config.hardware.facter = {
    reportPath = if builtins.pathExists ../facter.json then ../facter.json else null;

    detected.dhcp.enable = false;
  };
}

{
  config,
  lib,
  settings,
  ...
}:
let
  profiles = settings.hardwareProfiles or { };
  cfg = profiles.nvidia or { };
  powerCfg = cfg.powerManagement or { };
  primeCfg = cfg.prime or { };
  offloadCfg = primeCfg.offload or { };

  enabled = cfg.enable or false;
  offloadEnabled = offloadCfg.enable or false;
in
lib.mkIf enabled {
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables =
    lib.mkIf (!offloadEnabled && lib.elem "nvidia" config.services.xserver.videoDrivers)
      {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

  hardware.nvidia = {
    branch = cfg.branch or "stable";
    open = cfg.open or null;
    nvidiaSettings = false;

    powerManagement = {
      enable = powerCfg.enable or false;
      finegrained = powerCfg.finegrained or false;
    };

    prime = lib.mkIf offloadEnabled {
      intelBusId = primeCfg.intelBusId or "";
      amdgpuBusId = primeCfg.amdgpuBusId or "";
      nvidiaBusId = primeCfg.nvidiaBusId or "";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };
}

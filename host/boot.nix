{
  boot = {
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
  };
}

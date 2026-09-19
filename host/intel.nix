{
  config,
  lib,
  pkgs,
  ...
}:
let
  graphicsCards = config.hardware.facter.report.hardware.graphics_card or [ ];

  hasIntelGraphics = lib.any (gpu: (gpu.vendor.hex or null) == "8086") graphicsCards;
in
{
  hardware.graphics.extraPackages =
    lib.mkIf (config.hardware.facter.enable && config.hardware.graphics.enable && hasIntelGraphics)
      [
        pkgs.intel-media-driver
        pkgs.intel-vaapi-driver
      ];
}

{ config, lib, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  programs.swaylock = {
    enable = true;

    settings = {
      font = config.stylix.fonts.monospace.name;
      indicator-idle-visible = true;
      indicator-thickness = 6;
      ring-color = lib.mkForce colors.base03;
    };
  };
}

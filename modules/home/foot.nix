{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  programs.foot = {
    enable = true;

    settings = {
      colors-dark.cursor = "${colors.base00} ${colors.base05}";
      mouse.hide-when-typing = "yes";
      scrollback.lines = 10000;
    };
  };
}

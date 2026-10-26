{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    jq
    playerctl
    slurp
    wl-clipboard
  ];

  programs.bash.profileExtra = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
      exec systemd-cat --identifier=hyprland start-hyprland
    fi
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    settings.config = {
      general = {
        "col.active_border" = lib.mkForce "rgb(${colors.base05})";
        "col.inactive_border" = lib.mkForce "rgb(${colors.base00})";
      };

      input = {
        kb_layout = osConfig.services.xserver.xkb.layout;
        kb_variant = osConfig.services.xserver.xkb.variant;
      };
    };

    extraLuaFiles = {
      "010-monitors" = ./monitors.lua;
      "020-appearance" = ./appearance.lua;
      "030-misc" = ./misc.lua;
      "040-bindings" = ./bindings.lua;
      "050-rules" = ./rules.lua;
    };
  };
}

{ config, lib, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "no-rc no-cursor";

    settings = {
      cursor_blink_interval = 0;
      enable_audio_bell = false;
      mouse_hide_wait = -1;
      remember_window_size = false;
      scrollback_lines = 10000;
    };

    extraConfig = lib.mkAfter ''
      tab_bar_background ${colors.base00}
      inactive_tab_background ${colors.base00}
    '';
  };
}

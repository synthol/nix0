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
  };
}

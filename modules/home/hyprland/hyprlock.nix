{ config, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
        immediate_render = true;
      };

      animations.enabled = false;

      input-field = {
        size = "240, 48";
        outline_thickness = 2;
        rounding = 0;
        fade_on_empty = false;
        font_family = config.stylix.fonts.monospace.name;
        placeholder_text = "Password";
      };
    };
  };
}

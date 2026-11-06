{ config, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;

  workspaceColors = background: text: {
    inherit background text;
    border = background;
  };
in
{
  programs.i3status = {
    enable = true;
    enableDefault = false;

    general = {
      interval = 5;
      color_bad = colors.base08;
      color_degraded = colors.base03;
    };

    modules = {
      memory = {
        position = 1;
        settings = {
          format = "MEM %used";
          memory_used_method = "memavailable";
        };
      };

      "volume master" = {
        position = 2;
        settings = {
          format = "VOL %volume";
          format_muted = "MUTE";
        };
      };

      "battery all" = {
        position = 3;
        settings = {
          format = "BAT %percentage%status";
          format_down = "";
          format_percentage = "%.00f%s";
          last_full_capacity = true;
          low_threshold = 20;
          threshold_type = "percentage";
          status_bat = "";
          status_chr = "+";
          status_full = "";
          status_idle = "";
          status_unk = "";
        };
      };

      time = {
        position = 4;
        settings.format = "%Y-%m-%d %H:%M";
      };
    };
  };

  wayland.windowManager.sway.config.bars = [
    {
      position = "top";
      statusCommand = "i3status";

      fonts = {
        names = [ config.stylix.fonts.monospace.name ];
        size = 9.0;
      };

      colors = {
        background = colors.base00;
        statusline = colors.base05;
        focusedWorkspace = workspaceColors colors.base05 colors.base00;
        activeWorkspace = workspaceColors colors.base00 colors.base05;
        inactiveWorkspace = workspaceColors colors.base00 colors.base03;
        urgentWorkspace = workspaceColors colors.base08 colors.base00;
        bindingMode = workspaceColors colors.base0B colors.base00;
      };

      extraConfig = ''
        modifier none
      '';
    }
  ];
}

{ config, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      targets = [ "hyprland-session.target" ];
    };

    settings.mainBar = {
      layer = "top";
      height = 26;
      passthrough = true;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "backlight"
        "battery"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        sort-by = "number";
      };

      clock = {
        format = "{:%a %b %d %H:%M}";
      };

      pulseaudio = {
        format = "VOL {volume}%";
        format-muted = "MUTE";
      };

      backlight = {
        format = "BRT {percent}%";
      };

      battery = {
        interval = 5;
        format = "BAT {capacity}%";
        format-charging = "BAT {capacity}%+";

        states = {
          warning = 20;
          critical = 10;
        };
      };
    };

    style = ''
      * {
        background: transparent;
        border: none;
        border-radius: 0;
        box-shadow: none;
        min-height: 0;
        font-family: "${config.stylix.fonts.monospace.name}";
        font-size: 12px;
      }

      window#waybar {
        background: ${colors.base00};
        color: ${colors.base05};
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #workspaces button {
        color: ${colors.base03};
        margin: 3px;
        min-width: 20px;
        padding: 0;
      }

      #workspaces button.active,
      #workspaces button.visible {
        background: ${colors.base05};
        color: ${colors.base00};
        font-weight: bold;
      }

      #workspaces button.urgent {
        background: ${colors.base08};
        color: ${colors.base00};
      }

      #clock,
      #pulseaudio,
      #backlight,
      #battery {
        padding: 0 7px;
      }

      #pulseaudio.muted {
        color: ${colors.base03};
      }

      #battery.warning {
        color: ${colors.base0A};
      }

      #battery.critical {
        color: ${colors.base08};
      }
    '';
  };
}

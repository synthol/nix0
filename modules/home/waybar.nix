{ config, pkgs, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  jq = "${pkgs.jq}/bin/jq";
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

      modules-left = [
        "hyprland/workspaces"
        "custom/layout"
      ];
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

      "custom/layout" = {
        exec = "{ ${hyprctl} -j monitors; ${hyprctl} -j workspaces; } | ${jq} -rs --arg output \"$WAYBAR_OUTPUT_NAME\" '(.[0][] | select(.name == $output) | .activeWorkspace.id) as $id | .[1][] | select(.id == $id) | .tiledLayout | ascii_upcase'";
        signal = 8;
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

      #workspaces button {
        color: ${colors.base03};
        margin: 3px;
        min-width: 20px;
        padding: 0;
      }

      #workspaces button.visible {
        color: ${colors.base05};
      }

      #workspaces button.active {
        background: ${colors.base05};
        color: ${colors.base00};
        font-weight: bold;
      }

      #workspaces button.urgent {
        background: ${colors.base08};
        color: ${colors.base00};
      }

      #custom-layout,
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

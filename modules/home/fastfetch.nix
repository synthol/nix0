{ config, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        source = "nixos_old_small";
        color = {
          "1" = colors.base0B;
          "2" = colors.base0B;
        };

        padding = {
          top = 1;
          left = 2;
          right = 3;
        };
      };

      display = {
        brightColor = false;
        color.keys = colors.base04;
        separator = "  ";
        key.width = 11;
        percent.type = [ "num" ];
      };

      modules = [
        "break"
        "os"
        "kernel"
        "packages"
        "shell"
        {
          type = "wm";
          key = "Desktop";
        }
        "terminal"
        {
          type = "terminalfont";
          key = "Font";
        }
        "cursor"
        "break"
        {
          type = "host";
          key = "System";
        }
        {
          type = "display";
          compactType = "original-with-refresh-rate";
        }
        "cpu"
        {
          type = "gpu";
          key = "GPU";
        }
        "break"
        "memory"
        {
          type = "disk";
          key = "Disk";
          folders = "/nix";
        }
        {
          type = "battery";
          key = "Battery";
        }
        "uptime"
        {
          type = "datetime";
          key = "Date/Time";
        }
        "break"
      ];
    };
  };
}

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
        separator = "";
        key.width = 8;
      };

      modules = [
        "break"
        {
          type = "os";
          key = "os";
          format = "{pretty-name}";
        }
        {
          type = "kernel";
          key = "kernel";
          format = "{release}";
        }
        {
          type = "packages";
          key = "pkgs";
          format = "{all}";
        }
        {
          type = "shell";
          key = "shell";
        }
        {
          type = "uptime";
          key = "uptime";
          format = "{?days}{days}d {?}{hours}h {minutes}m";
        }
        {
          type = "memory";
          key = "memory";
          format = "{used} / {total}";
        }
        {
          type = "disk";
          key = "disk";
          folders = "/nix";
          format = "{size-used} / {size-total}";
        }
        "break"
      ];
    };
  };
}

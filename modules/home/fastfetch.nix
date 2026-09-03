{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        source = "NixOS2";

        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };

      display = {
        separator = "  ";
        key.width = 15;
      };

      modules = [
        "break"
        {
          type = "title";
          color = {
            user = "magenta";
            host = "cyan";
          };
        }
        {
          type = "separator";
          string = "─";
        }
        "break"
        {
          type = "os";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "├─ Kernel";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "├─ Packages";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "└─ Shell";
          keyColor = "yellow";
        }
        "break"
        {
          type = "wm";
          key = "Desktop";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "├─ Terminal";
          keyColor = "blue";
        }
        {
          type = "terminalfont";
          key = "├─ Font";
          keyColor = "blue";
        }
        {
          type = "cursor";
          key = "└─ Cursor";
          keyColor = "blue";
        }
        "break"
        {
          type = "host";
          key = "System";
          keyColor = "green";
        }
        {
          type = "display";
          key = "├─ Display";
          keyColor = "green";
          compactType = "original-with-refresh-rate";
        }
        {
          type = "cpu";
          key = "├─ CPU";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "├─ GPU";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "├─ Memory";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "├─ Disk";
          keyColor = "green";
          folders = "/nix";
        }
        {
          type = "battery";
          key = "├─ Battery";
          keyColor = "green";
          percent.type = [ "num" ];
        }
        {
          type = "uptime";
          key = "├─ Uptime";
          keyColor = "green";
        }
        {
          type = "datetime";
          key = "└─ Date/Time";
          keyColor = "green";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          paddingLeft = 2;
        }
        "break"
      ];
    };
  };
}

{ config, ... }:
{
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplicationPackages = [ config.programs.brave-origin.finalPackage ];
    };

    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}

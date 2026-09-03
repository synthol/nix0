{ config, ... }:
{
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplicationPackages = [ config.programs.librewolf.finalPackage ];
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

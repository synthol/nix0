{ config, ... }:
{
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplicationPackages = [ config.programs.qutebrowser.package ];
      defaultApplications."application/pdf" = "org.qutebrowser.qutebrowser.desktop";
    };

    terminal-exec = {
      enable = true;
      settings.default = [ "foot.desktop" ];
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}

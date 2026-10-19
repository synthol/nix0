{ pkgs, ... }:
{
  gtk = {
    colorScheme = "dark";
  };

  stylix.targets.gnome.enable = false;

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
}

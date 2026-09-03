{ pkgs, ... }:
{
  gtk = {
    colorScheme = "dark";
  };

  stylix.targets.gnome.enable = false;

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}

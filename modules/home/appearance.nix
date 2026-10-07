{ pkgs, ... }:
let
  cursorTheme = "Bibata-Modern-Classic";

  cursorPackage = pkgs.runCommand cursorTheme { } ''
    mkdir -p "$out/share/icons"
    cp -r ${pkgs.bibata-cursors}/share/icons/${cursorTheme} "$out/share/icons/"
  '';
in
{
  gtk = {
    colorScheme = "dark";
  };

  stylix.targets.gnome.enable = false;

  home.pointerCursor = {
    enable = true;
    package = cursorPackage;
    name = cursorTheme;
    size = 24;
  };
}

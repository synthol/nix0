{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland // {
      override = _: pkgs.hyprland;
    };
  };

  services.speechd.enable = false;
}

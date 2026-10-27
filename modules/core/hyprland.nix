{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland // {
      override = _: pkgs.hyprland;
    };
  };

  security.pam.services.hyprlock = { };
  services.speechd.enable = false;
}

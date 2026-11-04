{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = false;
    packages = [ pkgs.unifont ];
  };

  programs.sway = {
    enable = true;
    extraPackages = [ ];
  };

  services.speechd.enable = false;
}

{ lib, ... }:
{
  programs.qutebrowser = {
    enable = true;

    settings = {
      content.headers.accept_language = null;
      content.pdfjs = true;
      fonts.web.size.default = lib.mkForce 16;
      qt.force_platformtheme = "xdgdesktopportal";
    };
  };
}

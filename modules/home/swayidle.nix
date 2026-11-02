{ osConfig, pkgs, ... }:
let
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  lockSession = "${pkgs.swaylock}/bin/swaylock -f";
  dpmsCommand = action: "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  services.swayidle = {
    enable = true;

    timeouts = [
      {
        timeout = 300;
        command = lockSession;
      }
      {
        timeout = 600;
        command = dpmsCommand "disable";
        resumeCommand = dpmsCommand "enable";
      }
    ];

    events = {
      before-sleep = lockSession;
      after-resume = dpmsCommand "enable";
      lock = lockSession;
    };
  };
}

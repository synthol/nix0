{ osConfig, pkgs, ... }:
let
  lockSession = "${pkgs.swaylock}/bin/swaylock -f";
  powerCommand = state: "${osConfig.programs.sway.package}/bin/swaymsg 'output * power ${state}'";
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
        command = powerCommand "off";
        resumeCommand = powerCommand "on";
      }
    ];

    events = {
      before-sleep = lockSession;
      after-resume = powerCommand "on";
      lock = lockSession;
    };
  };
}

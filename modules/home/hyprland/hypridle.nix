{ pkgs, ... }:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  lockSession = "${pkgs.systemd}/bin/loginctl lock-session";
  dpmsCommand = action: "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = lockSession;
        after_sleep_cmd = dpmsCommand "enable";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = lockSession;
        }
        {
          timeout = 600;
          on-timeout = dpmsCommand "disable";
          on-resume = dpmsCommand "enable";
        }
      ];
    };
  };
}

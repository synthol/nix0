{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors.withHashtag;
  xkb = osConfig.services.xserver.xkb;

  screenshotFile = ''"$(xdg-user-dir PICTURES)/Screenshot-$(date +%Y%m%d-%H%M%S-%N).png"'';

  focusedBorder =
    color: "client.focused ${color} ${colors.base00} ${colors.base05} ${colors.base0B} ${color}";
  enterResize = ''mode "resize"; ${focusedBorder colors.base0B}'';
  leaveResize = ''mode "default"; ${focusedBorder colors.base05}'';

  windowColors = color: {
    border = lib.mkForce color;
    childBorder = lib.mkForce color;
  };

  workspaceBindings = lib.mergeAttrsList (
    map (
      workspace:
      let
        key = toString (workspace + 9);
        number = toString workspace;
      in
      {
        "--no-repeat Mod4+${key}" = "workspace number ${number}";
        "--no-repeat Mod4+Shift+${key}" = "move container to workspace number ${number}";
      }
    ) (lib.range 1 10)
  );
in
{
  home.packages = with pkgs; [
    brightnessctl
    grim
    playerctl
    slurp
    wl-clipboard
  ];

  programs.bash.profileExtra = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
      exec systemd-cat --identifier=sway sway
    fi
  '';

  wayland.windowManager.sway = {
    enable = true;
    package = osConfig.programs.sway.package;

    extraConfig = ''
      swaybg_command -

      mode "resize" {
        bindcode 43 resize shrink width 10 px
        bindcode 44 resize grow height 10 px
        bindcode 45 resize shrink height 10 px
        bindcode 46 resize grow width 10 px
        bindsym Left resize shrink width 10 px
        bindsym Down resize grow height 10 px
        bindsym Up resize shrink height 10 px
        bindsym Right resize grow width 10 px
        bindsym Return ${leaveResize}
        bindsym Escape ${leaveResize}
      }
    '';

    config = {
      modifier = "Mod4";
      bars = [ ];
      modes = { };

      focus = {
        newWindow = "urgent";
        wrapping = "yes";
      };

      seat."*".hide_cursor = "when-typing enable";

      window = {
        border = 1;
        titlebar = false;
        hideEdgeBorders = "smart";
      };

      floating = {
        border = 1;
        titlebar = false;
      };

      colors = {
        focused = windowColors colors.base05;
        focusedInactive = windowColors colors.base00;
        unfocused = windowColors colors.base00;
      };

      input = {
        "type:keyboard" = {
          xkb_layout = xkb.layout;
        }
        // lib.optionalAttrs (xkb.variant != "") { xkb_variant = xkb.variant; };

        "type:touchpad".tap = "enabled";
      };

      keycodebindings = workspaceBindings // {
        "--no-repeat Mod4+28" = "exec foot";
        "--no-repeat Mod4+Mod1+46" = "exec swaylock";
        "--no-repeat Mod4+56" =
          "exec systemctl --user kill --kill-whom=main --signal=SIGUSR1 waybar.service";

        "--no-repeat Mod4+54" = "kill";
        "--no-repeat --inhibited Mod4+41" = "fullscreen toggle";
        "--no-repeat Mod4+39" = "split toggle";
        "--no-repeat Mod4+Shift+39" = "split none";
        "--no-repeat Mod4+27" = enterResize;

        "--no-repeat Mod4+43" = "focus left";
        "--no-repeat Mod4+44" = "focus down";
        "--no-repeat Mod4+45" = "focus up";
        "--no-repeat Mod4+46" = "focus right";

        "Mod4+Shift+43" = "move left";
        "Mod4+Shift+44" = "move down";
        "Mod4+Shift+45" = "move up";
        "Mod4+Shift+46" = "move right";
      };

      keybindings = {
        "--no-repeat Print" = "exec grim ${screenshotFile}";
        "--no-repeat Mod4+Print" = ''exec geometry="$(slurp)" && grim -g "$geometry" ${screenshotFile}'';

        "--no-repeat Mod4+Left" = "focus left";
        "--no-repeat Mod4+Down" = "focus down";
        "--no-repeat Mod4+Up" = "focus up";
        "--no-repeat Mod4+Right" = "focus right";

        "Mod4+Shift+Left" = "move left";
        "Mod4+Shift+Down" = "move down";
        "Mod4+Shift+Up" = "move up";
        "Mod4+Shift+Right" = "move right";

        "--locked XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        "--locked XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "--locked --no-repeat XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "--locked --no-repeat XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        "--locked --no-repeat XF86AudioPrev" = "exec playerctl previous";
        "--locked --no-repeat XF86AudioPlay" = "exec playerctl play-pause";
        "--locked --no-repeat XF86AudioPause" = "exec playerctl play-pause";
        "--locked --no-repeat XF86AudioNext" = "exec playerctl next";

        "--locked XF86MonBrightnessUp" = "exec brightnessctl -e4 -n2 set 5%+";
        "--locked XF86MonBrightnessDown" = "exec brightnessctl -e4 -n2 set 5%-";
      };
    };
  };
}

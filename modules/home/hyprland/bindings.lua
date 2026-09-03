local keycode = {
  b = "code:56",
  c = "code:54",
  f = "code:41",
  h = "code:43",
  j = "code:44",
  k = "code:45",
  l = "code:46",
  t = "code:28",
}

hl.bind("SUPER + " .. keycode.t, hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + ALT + " .. keycode.l, hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + " .. keycode.b, hl.dsp.exec_cmd("systemctl --user kill --kill-whom=main --signal=SIGUSR1 waybar.service"))

hl.bind("Print", hl.dsp.exec_cmd([[grim "$(xdg-user-dir PICTURES)/Screenshot-$(date +%Y%m%d-%H%M%S).png"]]))
hl.bind("SUPER + Print", hl.dsp.exec_cmd([[geometry="$(slurp)" && grim -g "$geometry" "$(xdg-user-dir PICTURES)/Screenshot-$(date +%Y%m%d-%H%M%S).png"]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim - | wl-copy --type image/png]]))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd([[geometry="$(slurp)" && grim -g "$geometry" - | wl-copy --type image/png]]))
hl.bind("ALT + Print", hl.dsp.exec_cmd([[geometry="$(hyprctl -j activewindow | jq -er 'select(.at and .size) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" && grim -g "$geometry" "$(xdg-user-dir PICTURES)/Screenshot-$(date +%Y%m%d-%H%M%S).png"]]))
hl.bind("ALT + SHIFT + Print", hl.dsp.exec_cmd([[geometry="$(hyprctl -j activewindow | jq -er 'select(.at and .size) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" && grim -g "$geometry" - | wl-copy --type image/png]]))

hl.bind("SUPER + " .. keycode.c, hl.dsp.window.close())
hl.bind("SUPER + " .. keycode.f, hl.dsp.window.fullscreen(), { dont_inhibit = true })
hl.bind("SUPER + SHIFT + " .. keycode.f, hl.dsp.window.fullscreen({ mode = "maximized" }), { dont_inhibit = true })

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + " .. keycode.h, hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + " .. keycode.j, hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + " .. keycode.k, hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + " .. keycode.l, hl.dsp.focus({ direction = "r" }))

for workspace = 1, 10 do
  local workspace_keycode = "code:" .. (workspace + 9)
  hl.bind("SUPER + " .. workspace_keycode, hl.dsp.focus({ workspace = workspace }))
  hl.bind("SUPER + SHIFT + " .. workspace_keycode, hl.dsp.window.move({ workspace = workspace, follow = false }))
end

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind("SUPER + SHIFT + " .. keycode.h, hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }), { repeating = true })
hl.bind("SUPER + SHIFT + " .. keycode.j, hl.dsp.window.move({ direction = "d" }), { repeating = true })
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind("SUPER + SHIFT + " .. keycode.k, hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind("SUPER + SHIFT + " .. keycode.l, hl.dsp.window.move({ direction = "r" }), { repeating = true })

hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + " .. keycode.h, hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + " .. keycode.j, hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + " .. keycode.k, hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + " .. keycode.l, hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

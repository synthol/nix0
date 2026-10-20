hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

hl.window_rule({
  name = "hide-single-window-border",
  match = {
    float = false,
    workspace = "w[tv1]",
  },

  border_size = 0,
})

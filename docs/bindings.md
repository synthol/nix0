# Bindings

Hyprland bindings are defined in
[`bindings.lua`](../modules/home/hyprland/bindings.lua).
`Super` is the Windows/Meta key. Letter and workspace shortcuts use physical
key positions corresponding to a US QWERTY keyboard, so their positions remain
consistent across keyboard layouts.

## Applications and session

| Shortcut | Action |
|---|---|
| `Super+T` | Open a terminal |
| `Super+Alt+L` | Lock the session |
| `Super+B` | Toggle the status bar |

## Screenshots

| Shortcut | Capture | Destination |
|---|---|---|
| `Print` | All displays | Pictures |
| `Super+Print` | Selected region | Pictures |
| `Shift+Print` | All displays | Clipboard |
| `Super+Shift+Print` | Selected region | Clipboard |
| `Alt+Print` | Active-window rectangle | Pictures |
| `Alt+Shift+Print` | Active-window rectangle | Clipboard |

Screenshots are saved to the XDG Pictures directory as
`Screenshot-YYYYMMDD-HHMMSS-NNNNNNNNN.png`.
Active-window captures may include overlapping windows.

## Window state

| Shortcut | Action |
|---|---|
| `Super+C` | Close the active window |
| `Super+F` | Toggle fullscreen mode |
| `Super+Shift+F` | Toggle maximised mode |

## Window focus

| Shortcut | Alternative | Action |
|---|---|---|
| `Super+Left` | `Super+H` | Focus the window to the left |
| `Super+Down` | `Super+J` | Focus the window below |
| `Super+Up` | `Super+K` | Focus the window above |
| `Super+Right` | `Super+L` | Focus the window to the right |

## Workspaces

| Shortcut | Action |
|---|---|
| `Super+1` through `Super+9` | Focus the corresponding workspace |
| `Super+0` | Focus workspace 10 |
| `Super+Shift+1` through `Super+Shift+9` | Move the active window to the corresponding workspace without switching workspaces |
| `Super+Shift+0` | Move the active window to workspace 10 without switching workspaces |

## Window movement

| Shortcut | Alternative | Action |
|---|---|---|
| `Super+Shift+Left` | `Super+Shift+H` | Move the active window left |
| `Super+Shift+Down` | `Super+Shift+J` | Move the active window down |
| `Super+Shift+Up` | `Super+Shift+K` | Move the active window up |
| `Super+Shift+Right` | `Super+Shift+L` | Move the active window right |

## Window resizing

| Shortcut | Alternative | Action |
|---|---|---|
| `Super+Ctrl+Left` | `Super+Ctrl+H` | Decrease width by 10 pixels |
| `Super+Ctrl+Down` | `Super+Ctrl+J` | Increase height by 10 pixels |
| `Super+Ctrl+Up` | `Super+Ctrl+K` | Decrease height by 10 pixels |
| `Super+Ctrl+Right` | `Super+Ctrl+L` | Increase width by 10 pixels |

Move and resize shortcuts repeat while held.

## Audio

| Key | Action |
|---|---|
| Volume up (`XF86AudioRaiseVolume`) | Increase output volume by 5% |
| Volume down (`XF86AudioLowerVolume`) | Decrease output volume by 5% |
| Mute (`XF86AudioMute`) | Toggle output mute |
| Microphone mute (`XF86AudioMicMute`) | Toggle microphone mute |

Audio controls target the default PipeWire devices. These keys work while
locked; volume keys repeat while held.

## Media

| Key | Action |
|---|---|
| Previous (`XF86AudioPrev`) | Go to the previous track |
| Play (`XF86AudioPlay`) | Toggle playback |
| Pause (`XF86AudioPause`) | Toggle playback |
| Next (`XF86AudioNext`) | Go to the next track |

Media controls use `playerctl` and work while locked.

## Brightness

| Key | Action |
|---|---|
| Brightness up (`XF86MonBrightnessUp`) | Increase brightness |
| Brightness down (`XF86MonBrightnessDown`) | Decrease brightness |

Brightness controls use `brightnessctl` with an exponential curve and minimum
brightness protection. Both keys work while locked and repeat while held.
Media and brightness keys may require `Fn`, depending on the keyboard.

## Applying changes

After editing bindings, follow [Hyprland changes](settings.md#hyprland-changes)
to apply them.

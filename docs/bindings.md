# Bindings

Sway bindings are defined in [`sway.nix`](../modules/home/sway.nix).
`Super` is the Windows/Meta key. Letter and workspace shortcuts use physical
key positions corresponding to a US QWERTY keyboard, so their positions remain
consistent across keyboard layouts.

## General

| Shortcut | Action |
|---|---|
| `Super+T` | Open Foot |
| `Super+Alt+L` | Lock the session |
| `Super+B` | Toggle Swaybar |

## Screenshots

| Shortcut | Action |
|---|---|
| `Print` | Capture all displays |
| `Super+Print` | Capture a selected region |

Screenshots are saved to the XDG Pictures directory as
`Screenshot-YYYYMMDD-HHMMSS-NNNNNNNNN.png`.

## Window state

| Shortcut | Action |
|---|---|
| `Super+C` | Close the active window |
| `Super+F` | Toggle fullscreen mode |
| `Super+S` | Toggle the split direction of the active window |
| `Super+Shift+S` | Cancel the split of the active window |

`Super+F` works even while an application captures the keyboard.

## Window focus

| Shortcut | Alternative | Action |
|---|---|---|
| `Super+Left` | `Super+H` | Focus the window to the left |
| `Super+Down` | `Super+J` | Focus the window below |
| `Super+Up` | `Super+K` | Focus the window above |
| `Super+Right` | `Super+L` | Focus the window to the right |

## Window movement

| Shortcut | Alternative | Action |
|---|---|---|
| `Super+Shift+Left` | `Super+Shift+H` | Move the active window left |
| `Super+Shift+Down` | `Super+Shift+J` | Move the active window down |
| `Super+Shift+Up` | `Super+Shift+K` | Move the active window up |
| `Super+Shift+Right` | `Super+Shift+L` | Move the active window right |

These keys repeat while held.

## Window resizing

Press `Super+R` to enter resize mode, then:

| Key | Alternative | Action |
|---|---|---|
| `Left` | `H` | Decrease width by 10 pixels |
| `Down` | `J` | Increase height by 10 pixels |
| `Up` | `K` | Decrease height by 10 pixels |
| `Right` | `L` | Increase width by 10 pixels |
| `Enter` | `Esc` | Leave resize mode |

Swaybar shows `resize` while the mode is active, and the keys repeat
while held.

## Workspaces

| Shortcut | Action |
|---|---|
| `Super+1` through `Super+0` | Focus workspaces 1 through 10 |
| `Super+Shift+1` through `Super+Shift+0` | Move the active window to workspaces 1 through 10 without following it |

## Media keys

| Key | Action |
|---|---|
| Volume up (`XF86AudioRaiseVolume`) | Increase output volume by 5% |
| Volume down (`XF86AudioLowerVolume`) | Decrease output volume by 5% |
| Mute (`XF86AudioMute`) | Toggle output mute |
| Microphone mute (`XF86AudioMicMute`) | Toggle microphone mute |
| Previous (`XF86AudioPrev`) | Go to the previous track |
| Play (`XF86AudioPlay`) | Toggle playback |
| Pause (`XF86AudioPause`) | Toggle playback |
| Stop (`XF86AudioStop`) | Stop playback |
| Next (`XF86AudioNext`) | Go to the next track |
| Brightness up (`XF86MonBrightnessUp`) | Increase brightness |
| Brightness down (`XF86MonBrightnessDown`) | Decrease brightness |

These keys work while locked and may require `Fn`, depending on the keyboard.
Volume and brightness keys repeat while held.

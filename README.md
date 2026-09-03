<div align="center">
  <p>
    <img src=".github/assets/logo.png" alt="nix0" width="280">
  </p>
  <p>A minimal NixOS configuration built around Hyprland.</p>
  <p>
    <a href="https://github.com/synthol/nix0/stargazers">
      <img alt="Stars" src="https://img.shields.io/github/stars/synthol/nix0?style=for-the-badge&labelColor=000000&color=00D700&logo=starship&logoColor=0087D7">
    </a>
    <a href="https://github.com/synthol/nix0/actions/workflows/ci.yml">
      <img alt="CI" src="https://img.shields.io/github/actions/workflow/status/synthol/nix0/ci.yml?style=for-the-badge&label=CI&labelColor=000000&color=00D700&logo=githubactions&logoColor=0087D7">
    </a>
    <a href="https://nixos.org">
      <img alt="NixOS unstable" src="https://img.shields.io/badge/NixOS-unstable-00D700?style=for-the-badge&labelColor=000000&logo=nixos&logoColor=0087D7">
    </a>
    <a href="LICENSE">
      <img alt="MIT license" src="https://img.shields.io/badge/license-MIT-00D700?style=for-the-badge&labelColor=000000&logo=opensourceinitiative&logoColor=0087D7">
    </a>
  </p>
</div>

## Features

- **Desktop:** Preconfigured Hyprland session with Waybar
- **Theming:** Coordinated styling through Stylix
- **Vim-style navigation:** Unified keyboard controls across Hyprland, Neovim, Vimium, and more
- **Storage:** Disko-managed GPT, LUKS, Btrfs, and an ephemeral root with preserved state
- **Automation:** Hardware-aware installer and release updater
- **Virtualisation:** libvirt/QEMU/KVM with virt-manager and optional VFIO and Looking Glass

## Screenshots

<p align="center">
  <img src=".github/assets/screenshots/1.png" alt="Fastfetch and Neovim" width="100%"><br>
  <img src=".github/assets/screenshots/2.png" alt="Neovim and btop" width="49%">
  <img src=".github/assets/screenshots/3.png" alt="Hyprlock" width="49%">
</p>

## Purpose

nix0 is intended for users who want an intentionally small system or a
clean base they can expand themselves. It is designed around keyboard control
and terminal workflows, omitting common components such as an
application launcher and file manager. It removes visual distractions by
disabling blur, gaps, and animations.

Installed applications are launched directly from a terminal. For example:

```sh
librewolf
```

To keep an application running after closing the terminal:

```sh
librewolf & disown
```

Nix can run occasional tools without declaring them in the system
configuration. For example, view an image on demand:

```sh
nix run nixpkgs#imv -- image.png
```

Or temporarily make a package available:

```sh
nix shell nixpkgs#ripgrep
```

Packages not already cached require an internet connection. This keeps the
system small, but is less plug-and-play than configurations that preload large
application collections. Frequently used software should be declared in the
configuration.

## Installation

### Requirements

- An x86_64 system using UEFI
- Secure Boot disabled
- An internet connection
- A dedicated installation disk of at least 32 GiB

> [!WARNING]
> The installer erases the selected disk after displaying its identity and
> requiring explicit confirmation.

Create and boot installation media using an official
[NixOS ISO](https://nixos.org/download/), then connect to the internet and run:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run 'github:synthol/nix0/1.0.0#install'
```

After installation, run the shutdown command shown by the installer. Once fully
powered off, remove the installation media and start the computer. After
logging in, open a terminal with `Super+T`. If needed, connect to a network with:

```sh
nmtui connect
```

## Settings

Settings are defined in [`settings.json`](settings.json). After installation,
edit them with:

```sh
sudoedit /etc/nixos/settings.json
```

Apply the changes:

```sh
sudo nixos-rebuild switch --flake 'path:/etc/nixos#nixos'
```

| Setting | Purpose |
|---|---|
| `installDisk` | Installer-selected target; do not change after installation |
| `username` | User account; changing it after installation requires manual migration |
| `hostName`, `timeZone`, `locale` | System identity and regional settings |
| `xkbLayout`, `xkbVariant` | Keyboard layout |
| `git.*` | Git name and email |
| `allowDiscards` | LUKS discard/TRIM support |
| `battery.*` | 80% charge limit using generic or Acer WMI support |
| `hardwareProfiles.nvidia.*` | NVIDIA enablement, driver branch, open kernel modules, power management, and PRIME offload/bus IDs |
| `gpuPassthrough.*` | VFIO enablement and PCI devices, plus Looking Glass and shared-memory size |

When enabling the NVIDIA profile, set `hardwareProfiles.nvidia.open` to `true`
or `false`; leaving it `null` will fail evaluation with NVIDIA driver versions
560 or newer.

## Updates

Update to the latest stable nix0 release:

```sh
sudo nix run --no-write-lock-file 'path:/etc/nixos#update'
```

The updater validates the release, preserves user settings, keeps a backup, and
activates the new configuration.

The automatic updater replaces managed configuration files. If you modify
them, use a fork or merge future releases manually.

## Bindings

Bindings are defined in [`bindings.lua`](modules/home/hyprland/bindings.lua).

| Category | Examples | Purpose |
|---|---|---|
| Navigation | `Super+1–0`, `Super+Shift+1–0`, `Super+Arrow/H/J/K/L` | Change workspaces, move windows between them, and focus windows |
| Applications | `Super+T`, `Super+B` | Open a terminal and toggle Waybar |
| Window control | `Super+C/F`, `Super+Shift+F`, `Super+Shift/Ctrl+Arrow/H/J/K/L` | Close, fullscreen, maximise, move, and resize windows |
| Screenshots | `Print` with `Super`, `Shift`, or `Alt` | Save or copy full, region, and active-window screenshots |
| System and media | `Super+Alt+L`, volume, playback, and brightness keys | Lock, control audio and media, and adjust brightness |

Media and brightness keys may require `Fn`, depending on the keyboard.

## GPU passthrough

Inspect virtualisation support, IOMMU groups, GPUs, and suggested PCI addresses:

```sh
nix run 'path:/etc/nixos#vfio-info'
```

Set `gpuPassthrough.enable` to `true` and copy the selected addresses into
`gpuPassthrough.pciAddresses`, then prepare the new boot configuration:

```sh
sudo nixos-rebuild boot --flake 'path:/etc/nixos#nixos'
```

Reboot into the `gpu-passthrough` specialisation.

If you enable Looking Glass, see the
[Looking Glass B7 documentation](https://looking-glass.io/docs/B7/) for setup
and troubleshooting.

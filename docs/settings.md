# Settings

Edit [`settings.json`](../settings.json) at `/etc/nixos/settings.json`;
the installer fills in disk, account, and regional values from your choices.

| Setting | Purpose |
|---|---|
| `installDisk` | Installer-selected target; do not change after installation |
| `username` | User account; changing it after installation requires manual migration |
| `hostName`, `timeZone`, `locale` | System identity and regional settings |
| `xkbLayout`, `xkbVariant` | Keyboard layout |
| `git.*` | Git name and email; set both or leave both empty |
| `allowDiscards` | LUKS discard/TRIM support; rebuild with `boot` and reboot |
| [`battery.*`](battery-limits.md) | 80% battery charge limit |
| [`hardwareProfiles.nvidia.*`](nvidia.md) | NVIDIA drivers, power management, PRIME offload, and VA-API backend selection |
| `virtualisation.enable` | libvirt/QEMU/KVM with virt-manager; disabling keeps existing VMs and their disk usage in `/persist/var/lib/libvirt` |
| [`virtualisation.gpuPassthrough.*`](gpu-passthrough.md) | GPU passthrough and optional Looking Glass; requires `virtualisation.enable` |

## Applying changes

Rebuild with `switch` to apply changes:

```sh
sudo nixos-rebuild switch --flake 'path:/etc/nixos#nixos'
```

Use `boot` and reboot for kernel, initrd, or boot-time driver changes, as
described in the hardware guides.

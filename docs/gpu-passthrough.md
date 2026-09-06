# GPU passthrough

Requires firmware virtualisation/IOMMU support and a GPU available for the
host desktop.

Inspect virtualisation support, IOMMU groups, GPUs, and suggested PCI addresses:

```sh
nix run 'path:/etc/nixos#vfio-info'
```

If it reports inactive IOMMU or unavailable groups, enable IOMMU for a normal
boot before selecting devices. nix0 adds its IOMMU kernel parameter only in
the passthrough specialisation:

1. Enable VT-d (Intel) or AMD-Vi/IOMMU (AMD) in firmware; CPU virtualisation
   alone is insufficient.
2. Reboot and hold `Space` to show systemd-boot. Select the normal nix0/NixOS
   entry and press `e` to edit its kernel command line for this boot.
3. On Intel, append `intel_iommu=on`. Remove any disabling parameters such as
   `iommu=off` or `intel_iommu=off`. On AMD, firmware-enabled IOMMU is normally
   detected automatically; remove `iommu=off` or `amd_iommu=off` if present.
4. Press `Enter` to boot, then rerun `vfio-info` above.

The boot-menu edit is temporary and does not bind devices to VFIO. If groups
are still unavailable, resolve firmware/kernel IOMMU detection before
continuing; check the boot journal with `sudo journalctl -k -b`.

Set `gpuPassthrough.enable` to `true` in [`settings.json`](../settings.json)
and copy the selected group's endpoint
addresses into `gpuPassthrough.pciAddresses`. Use the original hexadecimal
addresses, such as `0000:01:00.0`, rather than PRIME's converted format.
Review every selected device: the group may contain audio or other devices
that will also become unavailable to the host. Do not include PCI bridges.

## Looking Glass

Set `gpuPassthrough.lookingGlass.enable` to `true` to add the client and shared
memory support. GPU passthrough must also be enabled. The default
`gpuPassthrough.lookingGlass.memoryMiB` is `64`; supported sizes are `32`, `64`,
`128`, `256`, `512`, and `1024` MiB.

nix0 supplies KVMFR at `/dev/kvmfr0`. The VM's shared-memory size must match
`gpuPassthrough.lookingGlass.memoryMiB`. Follow the
[Looking Glass B7 KVMFR documentation](https://looking-glass.io/docs/B7/ivshmem_kvmfr/#libvirt)
for VM configuration.
See the [Looking Glass B7 documentation](https://looking-glass.io/docs/B7/)
for guest, client, and input setup.

## Applying changes

After changing GPU passthrough or Looking Glass settings, rebuild with `boot`,
then reboot.

Select the `gpu-passthrough` specialisation when booting for GPU passthrough.
Use the normal entry to keep the host's usual device assignments. The
specialisation prepares host VFIO bindings and any enabled Looking Glass
support; VM configuration remains manual.

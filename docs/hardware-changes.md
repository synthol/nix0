# Hardware changes

nix0 automatically includes Intel video-acceleration drivers when the hardware
report contains an Intel GPU, including on hybrid systems.

The hardware report is generated during installation and is not refreshed automatically.
After replacing hardware such as a GPU, motherboard, or network/Bluetooth
adapter, regenerate it from the normal system rather than the passthrough
specialisation:

```sh
sudo nix run --inputs-from 'path:/etc/nixos' nixpkgs#nixos-facter -- --output /etc/nixos/facter.json
```

Review configured NVIDIA settings, PRIME bus IDs, and VFIO PCI addresses
against the new hardware, then rebuild with `boot` and reboot.

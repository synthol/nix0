# NVIDIA

The installer does not configure NVIDIA automatically. If Sway cannot start,
switch to TTY2 with `Ctrl+Alt+F2`, log in, and edit
[`settings.json`](../settings.json) at `/etc/nixos/settings.json`.

Sway starts automatically only on TTY1, so TTY2 provides a shell for setup.

Set `nvidia.enable` to `true` to enable the NVIDIA drivers. Set `nvidia.open`
to `true` or `false`; leaving it `null` fails evaluation with driver versions
560 or newer.

`nvidia.branch` defaults to `stable`. See the
[NixOS NVIDIA guide](https://wiki.nixos.org/wiki/NVIDIA) for driver and
open-module compatibility.

The `nvidia.powerManagement.enable` setting enables NVIDIA's suspend/resume
support; `nvidia.powerManagement.finegrained` enables runtime power management
on supported hybrid systems and requires PRIME offload. Both default to `false`.

## PRIME offload

For hybrid graphics systems, identify the integrated and NVIDIA GPUs:

```sh
nix shell nixpkgs#pciutils --command lspci -D -d ::03xx
```

Under `nvidia`, enable both `enable` and `prime.offload.enable`. Set
`prime.nvidiaBusId` and the matching `prime.intelBusId` or `prime.amdgpuBusId`;
leave the unused integrated-GPU field empty.

Convert each hexadecimal address `domain:bus:device.function` to decimal
`PCI:bus@domain:device:function`; for example, `0000:0a:00.0` becomes
`PCI:10@0:0:0`.

nix0 provides `nvidia-offload` when offload is enabled.

## VA-API backend selection

`nvidia.forceVaapiDriver` defaults to `false`. Set it to `true` when your
applications require `LIBVA_DRIVER_NAME=nvidia`. This forces the NVIDIA
VA-API backend throughout the session, independently of PRIME offload.
Leave it disabled when applications need an Intel or AMD VA-API backend.
Leaving it disabled does not disable VA-API or guarantee automatic NVIDIA
backend selection.

For individual applications, prefix their launch command with
`LIBVA_DRIVER_NAME=nvidia` instead.

## Applying changes

After changing the NVIDIA settings, rebuild with `boot`, then reboot.

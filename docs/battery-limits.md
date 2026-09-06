# Battery limits

Both battery options are disabled by default. Choose the method your hardware
supports in [`settings.json`](../settings.json):

| Setting | Use |
|---|---|
| `battery.generic.enable` | Batteries exposing `/sys/class/power_supply/BAT*/charge_control_end_threshold` |
| `battery.acerWmi.enable` | Acer laptops supported by [acer-wmi-battery](https://github.com/frederik-h/acer-wmi-battery/blob/main/MODELS.md) |

The generic method requests an 80% stop threshold and a 75% start threshold
where those controls exist. Acer WMI enables the firmware's 80% health mode.
Use one method and leave both disabled on unsupported hardware.

After enabling a method, rebuild with `boot`, then reboot.

Verify the generic stop threshold (`80`) and start threshold (`75`, if exposed):

```sh
cat /sys/class/power_supply/BAT*/charge_control_end_threshold
cat /sys/class/power_supply/BAT*/charge_control_start_threshold
```

For Acer WMI, verify health mode (`1`):

```sh
cat /sys/bus/wmi/drivers/acer-wmi-battery/health_mode
```

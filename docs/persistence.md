# Persistence

nix0 mounts its root filesystem in memory and recreates it on reboot.
`/nix`, `/persist`, and `/boot` are disk-backed. Selected system and home data
is preserved under `/persist` by
[`host/preservation.nix`](../host/preservation.nix).

| Data | Behaviour across reboots |
|---|---|
| `/nix` | Packages, the Nix database, and system generations survive |
| `/etc/nixos` | Configuration files survive |
| Network connections, Bluetooth state, and system journal | Preserved by the configured system paths |
| `/var/lib/libvirt` | libvirt state and VM disks stored here survive; other disk locations need their own persistence |
| `/persist/passwords` | Installer-created login password hashes survive |
| Desktop, Documents, Downloads, Music, Pictures, Projects, Public, Templates, Videos | Preserved home directories |
| `.ssh` and `.local/state/wireplumber` | Preserved home state |
| `.config/BraveSoftware/Brave-Origin` | Brave Origin profiles, extensions, and settings survive |
| Other home data, including shell history and `.cache` | Resets unless added to persistence |

## Preserving additional data

In `/etc/nixos/host/preservation.nix`, add new paths relative to your home
directory under `users.${settings.username}.directories`. The Brave entry
below is already included and illustrates the format:

```nix
(privateDirectory ".config/BraveSoftware/Brave-Origin")
```

System directories belong in `preservation.preserveAt."/persist".directories`;
individual files use the corresponding `files` list. See the
[Preservation examples](https://nix-community.github.io/preservation/examples.html)
for the available forms.

If the directory already contains data, close the application and copy that
data to a preserved location such as Documents before applying the change.
Rebuild with `boot`, then reboot.

After reboot, restore the saved data into the now-preserved directory before
opening the application.

# Updates

## Replace configuration

Download and extract the desired [nix0 release](https://github.com/synthol/nix0/releases).
Choose a newer release to update, or the currently installed release to
discard local configuration changes.

Back up `/etc/nixos` and data covered by custom persistence rules before
replacing files. To retain local modifications, merge the release manually instead.

Replace `/path/to/extracted-release/` below with the extracted directory
containing [`flake.nix`](../flake.nix). Keep the trailing slash:

```sh
sudo nix shell nixpkgs#rsync --command rsync -ac --delete --chown=root:root \
  --exclude='/settings.json' --exclude='/facter.json' --exclude='.git/' \
  /path/to/extracted-release/ /etc/nixos/
```

This retains settings, the hardware report, and `.git` directories. Other
configuration files are replaced and extra files deleted. Compare your
[`settings.json`](../settings.json) with the release's defaults and incorporate any required changes;
settings are not merged automatically. Persistent data and passwords are unchanged.

## Applying changes

Rebuild with `boot`, adding `--no-update-lock-file --no-write-lock-file`
to retain the release's pinned dependencies, then reboot.

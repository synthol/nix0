# Login password

nix0 sets `users.mutableUsers = false` and reads the login password hash from
`/persist/passwords/<username>`. A change made with `passwd` is overwritten
on activation or reboot.

Generate a replacement yescrypt hash interactively:

```sh
nix shell --inputs-from 'path:/etc/nixos' nixpkgs#mkpasswd --command mkpasswd --method=yescrypt
```

Replace the existing file's contents with that single hash line, keeping its
root ownership and `0600` permissions. For the current user:

```sh
sudoedit /persist/passwords/"$(id -un)"
```

Rebuild with `switch` to apply the login/sudo password change. The separate
LUKS passphrase is unchanged.

{
  config,
  lib,
  settings,
  ...
}:
{
  users = {
    mutableUsers = false;

    users.${settings.username} = {
      isNormalUser = true;
      hashedPasswordFile = "/persist/passwords/${settings.username}";

      extraGroups = [
        "networkmanager"
        "wheel"
      ]
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd";
    };
  };
}

{ settings, ... }:
{
  users = {
    mutableUsers = false;

    users.${settings.username} = {
      isNormalUser = true;
      hashedPasswordFile = "/persist/passwords/${settings.username}";

      extraGroups = [
        "libvirtd"
        "networkmanager"
        "wheel"
      ];
    };
  };
}

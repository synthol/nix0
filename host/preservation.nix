{ settings, ... }:
let
  privateDirectory = directory: {
    inherit directory;
    mode = "0700";
  };

  initrdDirectory = directory: {
    inherit directory;
    inInitrd = true;
  };
in
{
  preservation.enable = true;

  preservation.preserveAt."/persist" = {
    directories = [
      "/etc/nixos"
      (privateDirectory "/etc/NetworkManager/system-connections")
      "/var/lib/NetworkManager"
      (privateDirectory "/var/lib/bluetooth")
      "/var/lib/libvirt"
      (initrdDirectory "/var/lib/nixos")
      (initrdDirectory "/var/lib/systemd")
      {
        directory = "/var/log/journal";
        group = "systemd-journal";
        mode = "2755";
      }
    ];

    files = [
      {
        file = "/etc/machine-id";
        mode = "0444";
        inInitrd = true;
      }
    ];

    users.${settings.username}.directories = [
      (privateDirectory ".local/state/wireplumber")
      (privateDirectory ".ssh")
      "Desktop"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Projects"
      "Public"
      "Templates"
      "Videos"
    ];
  };

  services.journald.extraConfig = "SystemMaxUse=256M";

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}

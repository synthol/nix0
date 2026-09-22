{ settings, ... }:
let
  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  disko.devices = {
    disk.main = {
      device = settings.installDisk;

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            device = "${settings.installDisk}-part1";
            label = "EFI";
            size = "2G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          system = {
            device = "${settings.installDisk}-part2";
            label = "root";
            size = "100%";

            content = {
              type = "luks";
              name = "system";

              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "root"
                ];

                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsMountOptions;
                  };

                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = btrfsMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "mode=755" ];
    };
  };

  boot.initrd.luks.devices.system.allowDiscards = settings.allowDiscards;
  fileSystems."/persist".neededForBoot = true;
}

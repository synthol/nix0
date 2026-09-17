{ settings, ... }:
{
  imports = [
    ../modules/core
    ./battery.nix
    ./boot.nix
    ./disko.nix
    ./facter.nix
    ./nvidia.nix
    ./preservation.nix
  ];

  networking.hostName = settings.hostName;

  home-manager = {
    extraSpecialArgs = { inherit settings; };

    useGlobalPkgs = true;
    useUserPackages = true;
    users.${settings.username} = import ./home.nix;
  };

  system.stateVersion = "26.05";
}

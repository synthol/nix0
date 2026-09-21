{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vimium = {
      url = "github:philc/vimium";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      preservation,
      stylix,
      vimium,
      ...
    }:
    let
      settings = builtins.fromJSON (builtins.readFile ./settings.json);
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      localeList =
        pkgs.runCommand "glibc-supported-locales"
          {
            nativeBuildInputs = [
              pkgs.gnutar
              pkgs.xz
            ];
          }
          ''
            tar \
              --extract \
              --file ${pkgs.glibc.src} \
              --wildcards \
              --to-stdout \
              'glibc-*/localedata/SUPPORTED' \
              > "$out"
          '';
    in
    {
      diskoConfigurations.nixos = import ./host/disko.nix { inherit settings; };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit settings; };

        modules = [
          {
            nixpkgs.hostPlatform = system;
            home-manager.extraSpecialArgs = { inherit vimium; };
          }
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          preservation.nixosModules.preservation
          stylix.nixosModules.stylix

          ./host
        ];
      };

      packages.${system} = {
        install = pkgs.writeShellApplication {
          name = "nix0-install";

          runtimeInputs = [
            disko.packages.${system}.disko
            pkgs.ckbcomp
            pkgs.coreutils
            pkgs.gawk
            pkgs.gum
            pkgs.jq
            pkgs.kbd
            pkgs.mkpasswd
            pkgs.nix
            pkgs.nixos-facter
            pkgs.nixos-install
            pkgs.util-linux
            pkgs.xkeyboard_config
          ];

          text = ''
            export INSTALL_SOURCE=${self}
            export INSTALL_CKBCOMP=${pkgs.ckbcomp}/bin/ckbcomp
            export INSTALL_DISKO=${disko.packages.${system}.disko}/bin/disko
            export INSTALL_GUM=${pkgs.gum}/bin/gum
            export INSTALL_LOADKEYS=${pkgs.kbd}/bin/loadkeys
            export INSTALL_LOCALE_LIST=${localeList}
            export INSTALL_NIXOS_INSTALL=${pkgs.nixos-install}/bin/nixos-install
            export INSTALL_TZDIR=${pkgs.tzdata}/share/zoneinfo
            export INSTALL_XKB_RULES=${pkgs.xkeyboard_config}/share/X11/xkb/rules/base.lst

            exec ${pkgs.bash}/bin/bash ${./scripts/install.sh} "$@"
          '';
        };

        vfio-info = pkgs.writeShellApplication {
          name = "vfio-info";

          runtimeInputs = [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.pciutils
          ];

          text = ''
            exec ${pkgs.bash}/bin/bash ${./scripts/vfio-info.sh} "$@"
          '';
        };
      };
    };
}

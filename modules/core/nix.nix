{
  nix = {
    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    channel.enable = false;
  };

  nixpkgs.config.allowUnfree = true;
}

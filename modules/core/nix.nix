{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    channel.enable = false;
  };

  nixpkgs.config.allowUnfree = true;
}

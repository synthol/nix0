{ version, ... }:
{
  environment.etc."nix0-release".text = builtins.toJSON {
    id = "nix0";
    repository = "synthol/nix0";
    inherit version;
  };
}

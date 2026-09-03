{ lib, settings, ... }:
let
  cfg = settings.git or { };
  name = cfg.name or "";
  email = cfg.email or "";
in
{
  assertions = [
    {
      assertion = (name == "") == (email == "");
      message = "git.name and git.email must either both be set or both be empty.";
    }
  ];

  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";

      user = {
        useConfigOnly = true;
      }
      // lib.optionalAttrs (name != "") {
        inherit name email;
      };
    };
  };
}

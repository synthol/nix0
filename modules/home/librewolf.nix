{ firefoxAddons, ... }:
{
  programs.librewolf = {
    enable = true;

    globalExtensions = [
      {
        package = firefoxAddons.vimium;

        settings = {
          installation_mode = "normal_installed";
          updates_disabled = true;
        };
      }
    ];
  };

  stylix.targets.librewolf.enable = false;
}

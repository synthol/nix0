{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      AddKeysToAgent = "yes";
    };
  };

  services.ssh-agent.enable = true;
}

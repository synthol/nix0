{
  hardware.facter = {
    reportPath = if builtins.pathExists ../facter.json then ../facter.json else null;

    detected.dhcp.enable = false;
  };
}

{
  security.rtkit.enable = true;

  services.pipewire.extraConfig.pipewire.no-x11-bell."context.properties"."module.x11.bell" = false;
}

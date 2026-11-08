{
  lib,
  pkgs,
  settings,
  ...
}:
let
  cfg = settings.virtualisation or { };
in
lib.mkIf (cfg.enable or false) {
  programs.virt-manager.enable = true;

  systemd.services = {
    libvirtd-config.unitConfig.RequiresMountsFor = "/var/lib/libvirt";
    virt-secret-init-encryption.unitConfig.RequiresMountsFor = "/var/lib/libvirt";
  };

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };
}

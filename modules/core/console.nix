{
  boot.kernelParams = [ "vt.cur_default=6" ];
  systemd.tmpfiles.rules = [ "w /sys/class/graphics/fbcon/cursor_blink - - - - 0" ];

  services.getty.extraArgs = [ "--nohostname" ];
  environment.etc.issue.text = ''\e{green}\n\e{reset} '';
}

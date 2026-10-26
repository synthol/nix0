{
  boot.kernelParams = [ "vt.cur_default=6" ];
  systemd.tmpfiles.rules = [ "w /sys/class/graphics/fbcon/cursor_blink - - - - 0" ];

  environment.etc.issue.text = "";
}

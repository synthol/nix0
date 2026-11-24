{
  boot.kernelParams = [
    "fbcon=nodefer"
    "vt.cur_default=6"
  ];

  boot.initrd.services.udev.rules = ''
    ACTION=="add", SUBSYSTEM=="graphics", KERNEL=="fbcon", ATTR{cursor_blink}="0"
  '';

  environment.etc.issue.text = "";
}

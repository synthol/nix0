{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      sizes.terminal = 11;
    };

    base16Scheme = {
      base00 = "000000";
      base01 = "080808";
      base02 = "1C1C1C";
      base03 = "707070";
      base04 = "909090";
      base05 = "C8C8C8";
      base06 = "E0E0E0";
      base07 = "FFFFFF";
      base08 = "FF0000";
      base09 = "D75F00";
      base0A = "D7AF00";
      base0B = "00D700";
      base0C = "00AFAF";
      base0D = "0087D7";
      base0E = "D700D7";
      base0F = "AF5F00";
    };
  };
}

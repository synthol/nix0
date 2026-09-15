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
      base08 = "F7768E";
      base09 = "FF9E64";
      base0A = "E0AF68";
      base0B = "9ECE6A";
      base0C = "449DAB";
      base0D = "7AA2F7";
      base0E = "AD8EE6";
      base0F = "B59064";
    };
  };
}

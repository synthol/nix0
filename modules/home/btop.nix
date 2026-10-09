{ config, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  stylix.targets.btop.enable = false;

  programs.btop = {
    enable = true;

    settings = {
      color_theme = "nix0";
      theme_background = false;
      proc_colors = false;
      proc_gradient = false;
      rounded_corners = false;
      vim_keys = true;
    };

    themes.nix0 = ''
      theme[main_fg]="${colors.base05}"
      theme[title]="${colors.base05}"
      theme[hi_fg]="${colors.base0B}"
      theme[selected_bg]="${colors.base02}"
      theme[selected_fg]="${colors.base06}"
      theme[inactive_fg]="${colors.base03}"
      theme[graph_text]="${colors.base04}"
      theme[meter_bg]="${colors.base02}"
      theme[proc_misc]="${colors.base04}"
      theme[cpu_box]="${colors.base03}"
      theme[mem_box]="${colors.base03}"
      theme[net_box]="${colors.base03}"
      theme[proc_box]="${colors.base03}"
      theme[div_line]="${colors.base03}"
      theme[temp_start]="${colors.base0B}"
      theme[temp_mid]="${colors.base0B}"
      theme[temp_end]="${colors.base08}"
      theme[cpu_start]="${colors.base0B}"
      theme[cpu_mid]="${colors.base0A}"
      theme[cpu_end]="${colors.base08}"
      theme[free_start]="${colors.base0B}"
      theme[free_mid]="${colors.base0B}"
      theme[free_end]="${colors.base0B}"
      theme[cached_start]="${colors.base0B}"
      theme[cached_mid]="${colors.base0B}"
      theme[cached_end]="${colors.base0B}"
      theme[available_start]="${colors.base0B}"
      theme[available_mid]="${colors.base0B}"
      theme[available_end]="${colors.base0B}"
      theme[used_start]="${colors.base0B}"
      theme[used_mid]="${colors.base0B}"
      theme[used_end]="${colors.base08}"
      theme[download_start]="${colors.base0B}"
      theme[download_mid]="${colors.base0B}"
      theme[download_end]="${colors.base0B}"
      theme[upload_start]="${colors.base0B}"
      theme[upload_mid]="${colors.base0B}"
      theme[upload_end]="${colors.base0B}"
      theme[followed_bg]="${colors.base05}"
      theme[followed_fg]="${colors.base00}"
      theme[proc_pause_bg]="${colors.base05}"
      theme[proc_follow_bg]="${colors.base05}"
      theme[proc_banner_bg]="${colors.base05}"
      theme[proc_banner_fg]="${colors.base00}"
    '';
  };
}

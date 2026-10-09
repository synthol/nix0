{ pkgs, ... }:
{
  stylix.targets.neovim.transparentBackground.numberLine = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];

    initLua = ''
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.number = true
      vim.opt.wrap = false
      vim.opt.clipboard = "unnamedplus"
      vim.opt.guicursor = ""

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    '';
  };
}

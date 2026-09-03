{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    initLua = ''
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.number = true
      vim.opt.wrap = false
      vim.opt.clipboard = "unnamedplus"
    '';
  };
}

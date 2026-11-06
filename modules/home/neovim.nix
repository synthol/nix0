{ pkgs, ... }:
{
  stylix.targets.neovim.transparentBackground.numberLine = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        grammars: with grammars; [
          bash
          c
          c_sharp
          comment
          cpp
          css
          diff
          doxygen
          git_rebase
          gitcommit
          go
          html
          java
          javadoc
          javascript
          jsdoc
          json
          lua
          luadoc
          luap
          markdown
          markdown_inline
          nix
          php
          phpdoc
          printf
          python
          query
          regex
          rust
          sql
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ]
      ))
    ];

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

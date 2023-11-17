args @ { pkgs, ... }:
let
  conf = {
    lua = import ./lua.nix args;
    nix = import ./nix.nix args;
    python = import ./python.nix args;
  };

  nvim-dap = {
    plugin = pkgs.vimPlugins.nvim-dap;
    config = ''
      lua << EOF
      ${builtins.concatStringsSep "\n" (builtins.map (m: "do\n${m}\nend") [
        conf.python.nvim-dap
      ])}
      EOF
    '';
  };

  nvim-lspconfig = {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    config = ''
      lua << EOF
      ${builtins.concatStringsSep "\n" (builtins.map (m: "do\n${m}\nend") [
        conf.lua.nvim-lspconfig
        conf.nix.nvim-lspconfig
        conf.python.nvim-lspconfig
      ])}
      EOF
    '';
  };

  nvim-treesitter = {
    plugin = (pkgs.vimPlugins.nvim-treesitter.withPlugins (
      ps: with ps; [
        lua
        nix
        python
      ]
    ));
    config = ''
      lua << EOF
      require('nvim-treesitter.configs').setup {
        auto_install = false,
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<Tab>',
            node_incremental = '<Tab>',
            node_decremental = '<S-Tab>',
            scope_incremental = false,
          },
        },
      }
      EOF
    '';
  };
in
{
  programs.neovim = {
    extraLuaConfig = ''
      vim.o.colorcolumn = '80,100'
      vim.o.expandtab = true  -- Spaces instead of tabs.
      vim.o.shiftwidth = 2    -- # of spaces to use for each (auto)indent.
      vim.o.tabstop = 2       -- # of spaces a <Tab> in the file counts for.
    '';
    extraPackages = (
      conf.lua.extraPackages ++
      conf.nix.extraPackages ++
      conf.python.extraPackages
    );
    plugins = [
      nvim-dap
      nvim-lspconfig
      nvim-treesitter
    ];
    viAlias = true;
    vimAlias = true;
  };
}

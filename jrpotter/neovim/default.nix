args @ { config, pkgs, lib, ... }:
let
  utils = import ./utils.nix args;

  lualine-nvim = {
    plugin = pkgs.vimPlugins.lualine-nvim;
    config = ''
      require('init.evil')
    '';
  };

  nvim-cmp = {
    plugin = pkgs.vimPlugins.nvim-cmp;
    config = ''
      require('init.cmp').setup()
    '';
  };

  nvim-dap = {
    plugin = utils.pluginGit
      "e154fdb6d70b3765d71f296e718b29d8b7026a63"
      "mfussenegger/nvim-dap";
    config = config.programs.neovim.nvim-dap;
  };

  nvim-lspconfig = {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    config = config.programs.neovim.nvim-lspconfig;
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
      require('init.treesitter').setup()
    '';
  };
in
{
  options.programs.neovim = {
    nvim-dap = lib.mkOption {
      type = lib.types.lines;
      example = ''
        require('...').nvim_dap()
      '';
      description = lib.mdDoc ''
        Language-specific configurations for the `nvim-dap` plugin.
      '';
    };

    nvim-lspconfig = lib.mkOption {
      type = lib.types.lines;
      example = ''
        require('...').nvim_lspconfig()
      '';
      description = lib.mdDoc ''
        Language-specific configurations for the `nvim-lspconfig` plugin.
      '';
    };
  };

  imports = [
    ./lang/lean.nix
    ./lang/lua.nix
    ./lang/nix.nix
    ./lang/python.nix
  ];

  config = {
    programs.neovim = {
      defaultEditor = true;
      plugins = map (p:
        if builtins.hasAttr "config" p then {
          inherit (p) plugin;
          config = "lua << EOF\n${p.config}\nEOF";
        } else p) [
        lualine-nvim
        nvim-cmp
        nvim-dap
        nvim-lspconfig
        nvim-treesitter
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp_luasnip
        pkgs.vimPlugins.luasnip
        pkgs.vimPlugins.nvim-web-devicons
      ];
      viAlias = true;
      vimAlias = true;
    };

    xdg.configFile."nvim/init.lua".text = lib.mkMerge [
      # Extra Lua configuration to be prepended to `init.lua`. Extend the Lua
      # loader to search for our /nix/store/.../?.lua files.
      (let
        lua = pkgs.stdenv.mkDerivation {
          name = "lua";
          src = ./lua;
          installPhase = ''
            mkdir -p $out/
            cp -r ./* $out/
          '';
        };
        in lib.mkBefore ''
          package.path = '${lua}/?.lua;' .. package.path
        '')
      # Extra Lua configuration to be appended to `init.lua`.
      (lib.mkAfter ''
        vim.g.mapleader = ' '
        vim.g.maplocalleader = '\\'
        vim.o.colorcolumn = '80,100'
        vim.o.expandtab = true  -- Spaces instead of tabs.
        vim.o.list = true       -- Show hidden characters.
        vim.o.shiftwidth = 2    -- # of spaces to use for each (auto)indent.
        vim.o.tabstop = 2       -- # of spaces a <Tab> in the file counts for.
      '')
    ];
  };
}

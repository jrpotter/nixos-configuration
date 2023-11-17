{ config, pkgs, lib, ... }:
let
  pluginGit = rev: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = builtins.substring 0 7 rev;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };

  nvim-dap = {
    plugin = pluginGit
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
    ./lang/lua.nix
    ./lang/nix.nix
    ./lang/python.nix
  ];

  config = {
    programs.neovim = {
      plugins = map (p:
        if builtins.hasAttr "config" p then {
          inherit (p) plugin;
          config = "lua << EOF\n${p.config}\nEOF";
        } else p) [
        nvim-dap
        nvim-lspconfig
        nvim-treesitter
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
        vim.o.shiftwidth = 2    -- # of spaces to use for each (auto)indent.
        vim.o.tabstop = 2       -- # of spaces a <Tab> in the file counts for.
      '')
    ];
  };
}

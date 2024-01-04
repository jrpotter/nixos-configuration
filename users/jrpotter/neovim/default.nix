args @ { config, pkgs, lib, ... }:
let
  utils = import ./utils.nix args;

  colorscheme = {
    plugin = utils.pluginGit
      "eb82712f86319272f4b7b9dbb4ec6df650e6987f"
      "EdenEast/nightfox.nvim";
    config = ''
      vim.cmd('colorscheme nordfox')
    '';
  };

  lualine = {
    plugin = pkgs.vimPlugins.lualine-nvim;
    config = ''
      require('lualine').setup {
        sections = {
          lualine_x = {'encoding', 'filetype'},
          lualine_y = {
            require('utils.statusline').get_active_lsp,
            require('utils.statusline').get_dap_status,
          },
          lualine_z = {'%c:%l:%%%p'},
        },
      }
    '';
  };

  luasnip = {
    plugin = pkgs.vimPlugins.luasnip;
    config = ''
      ${config.programs.neovim.nvim-snippets}
    '';
  };

  nvim-cmp = {
    plugin = pkgs.vimPlugins.nvim-cmp;
    config = ''
      require('utils.cmp').setup()
    '';
  };

  nvim-dap = {
    plugin = utils.pluginGit
      "e154fdb6d70b3765d71f296e718b29d8b7026a63"
      "mfussenegger/nvim-dap";
    config = ''
      require('dap').defaults.fallback.terminal_win_cmd = 'below 10split new'
      ${config.programs.neovim.nvim-dap}
    '';
  };

  nvim-lspconfig = {
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    config = config.programs.neovim.nvim-lspconfig;
  };

  nvim-telescope = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      require('utils.telescope').setup()
    '';
  };

  nvim-treesitter = {
    plugin = (pkgs.vimPlugins.nvim-treesitter.withPlugins (
      ps: with ps; [
        bash
        c
        elixir
        heex
        html
        lua
        markdown
        nix
        python
        typescript
      ]
    ));
    config = ''
      require('utils.treesitter').setup()
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

    nvim-snippets = lib.mkOption {
      type = lib.types.lines;
      example = ''
        require('...').nvim_lspconfig()
      '';
      description = lib.mdDoc ''
        Language-specific configurations for the `luasnip` plugin.
      '';
    };
  };

  config = {
    home.packages = with pkgs; [
      ripgrep
    ];

    programs.neovim = {
      defaultEditor = true;
      plugins = map (p:
        if builtins.hasAttr "config" p then {
          inherit (p) plugin;
          config = "lua << EOF\n${p.config}\nEOF";
        } else p) [
        colorscheme  # Is always first.
        lualine
        luasnip
        nvim-cmp
        nvim-dap
        nvim-lspconfig
        nvim-telescope
        nvim-treesitter
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp_luasnip
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.vim-prettier
      ];
      viAlias = true;
      vimAlias = true;
    };

    xdg.configFile."nvim/init.lua".text =
      let
        config = import ./config { inherit pkgs; };
      in
        lib.mkMerge [
          # Extra Lua configuration to be prepended to `init.lua`. Extend the
          # Lua loader to search for our /nix/store/.../?.lua files.
          (lib.mkBefore ''
            package.path = '${config}/?.lua;' .. package.path
          '')
          # Extra Lua configuration to be appended to `init.lua`.
          (lib.mkAfter ''
            vim.g.mapleader = ' '
            vim.g.maplocalleader = '\\'
            vim.o.colorcolumn = '80,100'
            vim.o.equalalways = false -- Disable auto window resize.
            vim.o.expandtab = true    -- Spaces instead of tabs.
            vim.o.list = true         -- Show hidden characters.
            vim.o.shiftwidth = 2      -- # of spaces to use for each (auto)indent.
            vim.o.tabstop = 2         -- # of spaces a <Tab> in the file counts for.
          '')
        ];
  };
}

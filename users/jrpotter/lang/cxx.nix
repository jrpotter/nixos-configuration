{ pkgs, ... }:
let
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
  '';
in
{
  home.packages = with pkgs; [
    bear
    clang
    clang-tools
    codelldb
    gnumake
  ];

  programs.neovim = {
    nvim-dap = ''
      require('cxx.init').nvim_dap()
    '';

    nvim-lspconfig = ''
      require('cxx.init').nvim_lspconfig()

      vim.filetype.add({
        pattern = {
          ['.*%.h'] = 'c',
        },
      })
    '';

    nvim-snippets = ''
      require('luasnip').add_snippets('c', require('cxx.snippets'))
      require('luasnip').add_snippets('cpp', require('cxx.snippets'))
    '';
  };

  xdg.configFile."nvim/after/ftplugin/c.lua".text = ''
    require('utils.dap').buffer_map()
  '';
}

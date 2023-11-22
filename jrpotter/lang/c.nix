{ pkgs, ... }:
let
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    #!/usr/bin/env bash
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
      require('init.c').nvim_dap()
    '';

    nvim-lspconfig = ''
      require('init.c').nvim_lspconfig()
    '';
  };

  xdg.configFile."nvim/after/ftplugin/c.lua".text = ''
    require('init.dap').buffer_map()
  '';
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bear
    clang
    clang-tools
    (writeShellScriptBin "codelldb" ''
      #!/usr/bin/env bash
      exec ${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
    '')
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

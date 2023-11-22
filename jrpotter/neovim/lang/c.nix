{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clang-tools
    vscode-extensions.vadimcn.vscode-lldb
  ];

  programs.neovim = {
    nvim-dap = ''
      require('init.c').nvim_dap({
        command = '${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb'
      })
    '';

    nvim-lspconfig = ''
      require('init.c').nvim_lspconfig()
    '';
  };

  xdg.configFile."nvim/after/ftplugin/c.lua".text = ''
    require('init.dap').buffer_map()
  '';
}

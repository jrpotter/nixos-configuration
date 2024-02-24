{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      debugpy
      mccabe
      pycodestyle
      pyflakes
      python-lsp-server
      python-lsp-black
    ]))
  ];

  programs.neovim = {
    nvim-dap = ''
      require('lang.python').nvim_dap()
    '';

    nvim-lspconfig = ''
      require('lang.python').nvim_lspconfig()
    '';
  };

  xdg.configFile."nvim/after/ftplugin/python.lua".text = ''
    require('utils.dap').buffer_map()
  '';
}

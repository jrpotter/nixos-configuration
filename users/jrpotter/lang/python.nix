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
      require('python.init').nvim_dap()
    '';

    nvim-lspconfig = ''
      require('python.init').nvim_lspconfig()
    '';
  };

  xdg.configFile."nvim/after/ftplugin/python.lua".text = ''
    require('utils.dap').buffer_map()
  '';
}

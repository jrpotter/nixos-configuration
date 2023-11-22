{ ... }:
{
  home.extraPythonPackages = [
    "debugpy"
    "mccabe"
    "pycodestyle"
    "pyflakes"
    "python-lsp-server"
    "python-lsp-black"
  ];

  programs.neovim = {
    nvim-dap = ''
      require('init.python').nvim_dap()
    '';

    nvim-lspconfig = ''
      require('init.python').nvim_lspconfig()
    '';
  };

  xdg.configFile."nvim/after/ftplugin/python.lua".text = ''
    require('init.dap').buffer_map()
  '';
}

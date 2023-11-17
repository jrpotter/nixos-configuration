{ pkgs, ... }:
let
  venv = pkgs.python3.withPackages (ps: with ps; [
    debugpy
    mccabe
    pycodestyle
    pyflakes
    python-lsp-server
    python-lsp-black
  ]);
in
{
  programs.neovim = {
    nvim-dap = ''
      require('init.python').nvim_dap({
        command = '${venv}/bin/python3.10',
      })
    '';

    nvim-lspconfig = ''
      require('init.python').nvim_lspconfig()
    '';

    extraPackages = [ venv ];
  };

  xdg.configFile."nvim/after/ftplugin/python.lua".text = ''
    require('init.dap').buffer_map()
  '';
}

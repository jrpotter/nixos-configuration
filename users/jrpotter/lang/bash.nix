{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodePackages.bash-language-server
    shellcheck
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('utils.lsp').setup(require('lspconfig').bashls) {}
    '';
  };
}

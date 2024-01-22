{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodePackages.bash-language-server
    shellcheck
    shfmt
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('utils.lsp').setup(require('lspconfig').bashls) {}
    '';
  };
}

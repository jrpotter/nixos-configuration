{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').bashls) {}
    '';

    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
    ];
  };
}

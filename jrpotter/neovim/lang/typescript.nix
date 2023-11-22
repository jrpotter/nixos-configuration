{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodePackages.typescript-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').tsserver) {}
    '';
  };
}


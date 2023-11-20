{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').tsserver) {}
    '';

    extraPackages = with pkgs; [
      nodePackages.typescript-language-server
    ];
  };
}


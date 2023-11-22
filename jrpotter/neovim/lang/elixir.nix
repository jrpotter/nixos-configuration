{ pkgs, ... }:
{
  home.packages = with pkgs; [
    elixir-ls
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').elixirls) {
        cmd = { 'elixir-ls' },
      }
    '';
  };
}

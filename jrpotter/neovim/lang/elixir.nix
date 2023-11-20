{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').elixirls) {
        cmd = { 'elixir-ls' },
      }
    '';

    extraPackages = with pkgs; [
      elixir-ls
    ];
  };
}

{ pkgs, ... }:
{
  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').elixirls) {
        -- Keep command relative. Compatibility of `elixir-ls` depends tightly
        -- on -- the version of elixir being used so this allows local (i.e.
        -- within nix shells) versions of `elixir-ls` to override the version
        -- specified -- in `extraPackages`.
        cmd = { 'elixir-ls' },
      }
    '';

    extraPackages = with pkgs; [
      elixir-ls
    ];
  };
}

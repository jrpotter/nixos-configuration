{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodePackages.prettier
    nodePackages.typescript-language-server
  ];

  programs.neovim = {
    nvim-lspconfig = ''
      require('init.lsp').setup(require('lspconfig').tsserver) {
        on_attach = function(client, bufnr)
          require('init.lsp').on_attach(client, bufnr)
          -- Override the default formatter in typescript-language-server.
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gq', "<CMD>PrettierAsync<CR>", {
            silent = true,
          })
        end,
      }
    '';
  };
}


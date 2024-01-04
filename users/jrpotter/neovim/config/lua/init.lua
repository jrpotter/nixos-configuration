local M = {}

function M.nvim_lspconfig()
  require('utils.lsp').setup(require('lspconfig').lua_ls) {
    -- Provide completions, analysis, and location handling for plugins on the
    -- vim runtime path.
    -- https://github.com/neovim/nvim-lspconfig/blob/48347089666d5b77d054088aa72e4e0b58026e6e/doc/server_configurations.md#lua_ls
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if (
        not vim.loop.fs_stat(path .. '/.luarc.json') and
        not vim.loop.fs_stat(path .. '/.luarc.jsonc')
      ) then
        client.config.settings = vim.tbl_deep_extend(
          'force', client.config.settings, {
            Lua = {
              runtime = {
                version = 'LuaJIT'
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME
                }
              }
            }
          })

        client.notify("workspace/didChangeConfiguration", {
          settings = client.config.settings,
        })
      end
      return true
    end
  }
end

return M

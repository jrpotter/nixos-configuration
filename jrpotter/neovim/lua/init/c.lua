local M = {}

function M.nvim_dap(options)
  local dap = require('dap')
  local key = 'codelldb'

  dap.adapters[key] = {
    type = 'server',
    port = '${port}',
    executable = {
      command = options.command,
      args = {'--port', '${port}'},
    },
  }

  dap.configurations.c = dap.configurations.c or {}
  table.insert(dap.configurations.c, {
    name = 'Launch Executable',
    type = key,
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
  })
end

function M.nvim_lspconfig()
  require('init.lsp').setup(require('lspconfig').clangd) {}
end

return M

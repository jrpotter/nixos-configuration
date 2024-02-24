local M = {}

function M.nvim_dap()
  local dap = require('dap')
  local key = 'codelldb'

  dap.adapters[key] = {
    type = 'server',
    port = '${port}',
    executable = {
      command = 'codelldb',
      args = {'--port', '${port}'},
    },
  }

  local config = {
    name = 'Launch Executable',
    type = key,
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
  }

  dap.configurations.c = dap.configurations.c or {}
  table.insert(dap.configurations.c, config)

  dap.configurations.cpp = dap.configurations.cpp or {}
  table.insert(dap.configurations.cpp, config)
end

function M.nvim_lspconfig()
  require('utils.lsp').setup(require('lspconfig').clangd) {}
end

return M

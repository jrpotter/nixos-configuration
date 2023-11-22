local M = {}

function M.nvim_dap()
  local dap = require('dap')
  local key = 'debugpy'

  dap.adapters[key] = {
    type = 'executable',
    command = 'python3',
    args = { '-m', 'debugpy.adapter' },
    options = {
      source_filetype = 'python',
    },
  }

  dap.configurations.python = dap.configurations.python or {}
  table.insert(dap.configurations.python, {
    name = 'Launch File',
    type = key,
    request = 'launch',
    program = '${file}',
    cwd = '${workspaceFolder}',
  })
end

function M.nvim_lspconfig()
  require('init.lsp').setup(require('lspconfig').pylsp) {
    settings = {
      pylsp = {
        -- `flake8` currently fails in some cases. Prefer the default set of
        -- utilities instead.
        -- https://github.com/python-lsp/python-lsp-server/pull/434
        configurationSources = 'pycodestyle',
        plugins = {
          autopep8 = { enabled = false },
          black = { enabled = true },
          mccabe = { enabled = true },
          pycodestyle = { enabled = true },
          pyflakes = { enabled = true },
          yapf = { enabled = false },
        },
      },
    },
  }
end

return M

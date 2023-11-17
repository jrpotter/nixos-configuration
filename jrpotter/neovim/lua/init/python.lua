local module = {}

function module.nvim_dap(options)
  local dap = require('dap')

  dap.adapters.python = function(callback, config)
    callback({
      name = 'debugpy',
      type = 'executable',
      command = options.command,
      args = { '-m', 'debugpy.adapter' },
      options = {
        source_filetype = 'python',
      },
    })
  end

  dap.configurations.python = dap.configurations.python or {}
  table.insert(dap.configurations.python, {
    name = 'Launch',
    type = 'python',
    request = 'launch',
    program = '${file}',
    cwd = '${workspaceFolder}',
  })
end

function module.nvim_lspconfig()
  require('lspconfig').pylsp.setup {
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

return module

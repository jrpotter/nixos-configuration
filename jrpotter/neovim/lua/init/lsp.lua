local M = {}

local function on_attach(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gq', function()
    vim.lsp.buf.format { async = true }
  end, opts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

function M.setup(client)
  -- Return a nested function so that we can continue invoking `setup` in the
  -- familiar way.
  return function(opts)
    opts.on_attach = opts.on_attach or on_attach
    opts.cabailities = opts.cabailities or capabilities
    client.setup(opts)
  end
end

return M

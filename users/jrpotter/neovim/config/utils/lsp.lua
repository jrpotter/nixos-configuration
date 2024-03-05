local M = {}

function M.on_attach(client, bufnr)
  local function set_nnoremap(key, func)
    vim.keymap.set("n", key, func, { buffer = bufnr })
  end
  set_nnoremap("[d", vim.diagnostic.goto_prev)
  set_nnoremap("]d", vim.diagnostic.goto_next)
  set_nnoremap('g"', vim.lsp.buf.code_action)
  set_nnoremap("g?", vim.diagnostic.open_float)
  set_nnoremap("gq", function() vim.lsp.buf.format { async = true } end)
  set_nnoremap("gr", vim.lsp.buf.rename)
end

M.capabilities = require("cmp_nvim_lsp").default_capabilities()

function M.setup(client)
  -- Return a nested function so that we can continue invoking `setup` in the
  -- familiar way.
  return function(opts)
    opts.on_attach = opts.on_attach or M.on_attach
    opts.cabailities = opts.cabailities or M.capabilities
    client.setup(opts)
  end
end

return M

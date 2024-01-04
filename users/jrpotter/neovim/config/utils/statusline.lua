local M = {}

function M.get_active_lsp()
  local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
  local clients = vim.lsp.get_active_clients()
  if next(clients) == nil then
    return ""
  end
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      return string.format("  %s", client.name)
    end
  end
  return ""
end

function M.get_dap_status()
  local status = require('dap').status()
  if string.len(status) > 0 then
    return string.format("🪳 %s", status)
  else
    return ""
  end
end

return M

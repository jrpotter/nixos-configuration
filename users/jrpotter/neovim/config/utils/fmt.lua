local M = {}

function M.set_fmt_map()
  vim.keymap.set('v', 'g|', function()
    local width = vim.bo.textwidth
    if width == 0 and vim.w.colorcolumn then
      width = tonumber(vim.w.colorcolumn:match("[^,]+"))
    end
    return string.format("!par w%d<cr>", width ~= 0 and width or 80)
  end, { expr = true })
end

return M

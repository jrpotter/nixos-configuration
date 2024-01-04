local M = {}

local luasnip = require('luasnip')
local types = require('luasnip.util.types')
local f = require('luasnip').function_node

M.VISUAL = f(function(_, snip)
  local res, env = {}, snip.env
  for _, ele in ipairs(env.LS_SELECT_RAW) do
    table.insert(res, ele)
  end
  return res
end, {})

function M.setup()
  luasnip.config.setup {
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave',
    store_selection_keys = '<tab>',
    ext_opts = {
      [types.snippet] = {
        active = {
          virt_text = { { '●', 'DiagnosticWarn' } },
        },
      },
      [types.choiceNode] = {
        active = {
          virt_text = { { '⧨', 'DiagnosticHint' } },
          -- Include in case one of our choice options is an empty string.
          hl_group = 'DiagnosticOk',
        },
      },
    },
  }

  vim.keymap.set({ 'i', 's' }, '<c-e>', function()
    if luasnip.choice_active() then
      return '<Plug>luasnip-next-choice'
    else
      return '<c-e>'
    end
  end, { silent = true, expr = true, remap = true })

  vim.keymap.set({ 'i', 's' }, '<c-y>', function()
    if luasnip.choice_active() then
      return '<Plug>luasnip-prev-choice'
    else
      return '<c-y>'
    end
  end, { silent = true, expr = true, remap = true })

  -- Allow aborting the active snippet at any point in time.
  vim.keymap.set(
    { 'n', 'i', 's' },
    '<c-l>',
    '<cmd>LuaSnipUnlinkCurrent<cr>'
  )
end

return M

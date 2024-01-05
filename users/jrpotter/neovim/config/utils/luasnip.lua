local M = {}

local luasnip = require('luasnip')
local types = require('luasnip.util.types')

function M.visual_dynamic_node(pos)
  local f = luasnip.function_node
  local isn = luasnip.indent_snippet_node

  return isn(pos, {
    f(function(_, parent)
      return parent.snippet.env.LS_SELECT_DEDENT or {}
    end)
  }, '$PARENT_INDENT\t')
end

function M.choice_index(choice_node)
  for i, c in ipairs(choice_node.choices) do
    if c == choice_node.active_choice then
      return i
    end
  end
  return 1
end

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

  -- Track where we are expanding the snippet.
  luasnip.env_namespace('INFO', {
    init = function(info) return { POS = info.pos } end,
  })

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

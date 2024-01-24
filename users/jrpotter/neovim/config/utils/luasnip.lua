local M = {}

local luasnip = require('luasnip')
local types = require('luasnip.util.types')

function M.visual_isn(pos)
  local d = luasnip.dynamic_node
  local i = luasnip.insert_node
  local isn = luasnip.indent_snippet_node
  local sn = luasnip.snippet_node

  return isn(pos, d(1, function(_, parent)
    local res, env = {}, parent.snippet.env
    for _, ele in ipairs(env.LS_SELECT_DEDENT or {}) do
      table.insert(res, ele)
    end
    return sn(nil, i(1, res))
  end), '$PARENT_INDENT\t')
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
    enable_autosnippets = true,
    ext_opts = {
      [types.snippet] = {
        active = {
          virt_text = { { '●', 'DiagnosticWarn' } },
        },
      },
      [types.insertNode] = {
        passive = {
          hl_group = 'DiagnosticVirtualTextWarn',
        },
      },
      [types.choiceNode] = {
        active = {
          hl_group = 'DiagnosticVirtualTextHint',
          virt_text = { { '⧨', 'DiagnosticHint' } },
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

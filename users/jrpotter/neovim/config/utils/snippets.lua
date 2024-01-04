local M = {}

local luasnip = require('luasnip')
local d = luasnip.dynamic_node
local i = luasnip.insert_node
local sn = luasnip.snippet_node

-- Creates an insertion node with a default value of whatever was stored in the
-- visual selection prior to entering insert mode (refer to the configuration
-- field `store_selection_keys`).
function M.visual_dynamic_node(index, default)
  return d(index, function(_, parent)
    local res, env = {}, parent.snippet.env
    if type(env.LS_SELECT_RAW) ~= 'table' then
      return sn(nil, { i(1, default or '') }, '')
    end
    for k, v in ipairs(env.LS_SELECT_RAW) do
      local indent = env.CUSTOM_POS[2] - 1
      table.insert(res, (k == 1 and v) or string.rep(' ', indent) .. v)
    end
    if table.concat(res):match('^%s*$') then
      return sn(nil, { i(1, default or '') }, '')
    end
    return sn(nil, { i(1, res) }, '')
  end, {})
end

return M

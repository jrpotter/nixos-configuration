local s = require('luasnip').snippet
local i = require('luasnip').insert_node
local fmt = require('luasnip.extras.fmt').fmt

local v = require('utils.snippets').visual_dynamic_node

return {
  s(
    { name = 'for', trig = 'for' },
    fmt([[
for {} in {}:
  {}]],
      { i(1, ''), i(2, ''), v(3) }
    )
  ),
}

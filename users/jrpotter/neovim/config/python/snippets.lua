local fmt = require('luasnip.extras.fmt').fmt
local ls = require('luasnip')
local ul = require('utils.luasnip')

local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local r = ls.restore_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

return {
  s(
    { name = 'for', trig = 'for' },
    fmt([[
for {} in {}:
    {}]],
      {
        c(1, {
          i(nil, '_1'),
          i(nil, '_2'),
          i(nil, '_3'),
          { i(1, '_4'), t(', '), i(2, '_5') },
        }),
        d(2, function(_, parent)
          local index = ul.choice_index(parent.nodes[2])
          return sn(
            nil,
            r(1, string.format('for-%d', index), ({
              c(nil, {
                { t('range('), i(1, 'n'), t(')') },
                i(nil, 'val'),
              }),
              c(nil, {
                { i(1, 'dict'), t('.keys()') },
                i(nil, 'val'),
              }),
              c(nil, {
                { i(1, 'dict'), t('.values()') },
                i(nil, 'val'),
              }),
              c(nil, {
                { i(1, 'dict'), t('.items()') },
                i(nil, 'val'),
              }),
            })[index])
          )
        end, { 1 }),
        ul.visual_node,
      }
    )
  ),
}

local fmt = require('luasnip.extras.fmt').fmt
local ls = require('luasnip')
local ki = require('luasnip.nodes.key_indexer')
local ul = require('utils.luasnip')

local c = ls.choice_node
local d = ls.dynamic_node
local i = ls.insert_node
local k = ki.new_key
local r = ls.restore_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

return {
  s(
    { name = 'for', trig = 'for' },
    fmt([[
for (<>; <>) {
  <>
}]],
      {
        c(1, {
          sn(nil, {
            i(1, 'int'),
            t(' '),
            i(2, 'i'),
          }),
          sn(nil, {
            i(1, 'char *'),
            i(2, 'c'),
          }),
        }),
        d(2, function(_, parent)
          local index = ul.choice_index(parent.nodes[2])
          return sn(
            nil,
            r(1, string.format('for-%d', index), ({
              sn(nil, {
                i(1, 'i < N'),
                t('; '),
                i(2, '++i'),
              }),
              sn(nil, {
                i(1, 'c'),
                t('; '),
                i(2, '++c'),
              }),
            })[index])
          )
        end, { 1 }),
        ul.visual_isn(3),
      },
      { delimiters = '<>' }
    )
  ),
}

local fmt = require('luasnip.extras.fmt').fmt
local ls = require('luasnip')
local ul = require('utils.luasnip')

local c = ls.choice_node
local i = ls.insert_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

return {
  s(
    { name = 'for', trig = 'for' },
    fmt([[
for {} do
  {}
end]],
      {
        c(1, {
          sn(nil, {
            i(1, 'i'),
            t('='),
            i(2, 'm'),
            t(','),
            i(3, 'n'),
          }),
          sn(nil, {
            i(1, 'k'),
            t(', '),
            i(2, 'v'),
            t(' in pairs('),
            i(3, 'tbl'),
            t(')'),
          }),
          sn(nil, {
            i(1, 'i'),
            t(', '),
            i(2, 'v'),
            t(' in ipairs('),
            i(3, 'seq'),
            t(')'),
          }),
        }),
        ul.visual_isn(2),
      }
    )
  ),
}

local c = require('luasnip').choice_node
local d = require('luasnip').dynamic_node
local i = require('luasnip').insert_node
local sn = require('luasnip').snippet_node
local t = require('luasnip').text_node

local s = require('luasnip').snippet
local fmt = require('luasnip.extras.fmt').fmt

local VISUAL = require('utils.luasnip').VISUAL

return {
  s(
    { name = 'for', trig = 'for' },
    fmt([[
for {} in {}:
    {}]],
      {
        c(1, {
          i(1, 'i'),
          i(2, 'k'),
          i(3, 'v'),
          sn(4, { i(1, 'k'), t(', '), i(2, 'v') }),
        }),
        d(2, function(args, _, old_state)
          local default = i(nil, 'val')
          local snip = old_state or default

          if args[1][1] == 'i' then
            snip = sn(nil, c(1, {
              { t('range('), i(1, 'n'), t(')') },
              default,
            }))
          elseif args[1][1] == 'k' then
            snip = sn(nil, c(1, {
              { i(1, 'dict'), t('.keys()') },
              default,
            }))
          elseif args[1][1] == 'v' then
            snip = sn(nil, c(1, {
              { i(1, 'dict'), t('.values()') },
              default,
            }))
          elseif args[1][1] == 'k, v' then
            snip = sn(nil, c(1, {
              { i(1, 'dict'), t('.items()') },
              default,
            }))
          end

          snip.old_state = snip
          return snip
        end, { 1 }),
        VISUAL,
      }
    )
  ),
}

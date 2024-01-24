local ls = require('luasnip')

local s = ls.snippet
local t = ls.text_node

return {
  s(
    {
      trig = [[\_1]],
      wordTrig = false,
      snippetType = 'autosnippet',
    },
    t('₁')
  )
}

local ls = require('luasnip')

local s = ls.snippet
local t = ls.text_node

return {
  -- Subscripts
  s(
    { trig = [[_1]], wordTrig = false },
    t('₁')
  ),
  s(
    { trig = [[_2]], wordTrig = false },
    t('₂')
  ),
  s(
    { trig = [[_3]], wordTrig = false },
    t('₃')
  ),
  s(
    { trig = [[_4]], wordTrig = false },
    t('₄')
  ),
  s(
    { trig = [[_5]], wordTrig = false },
    t('₅')
  ),
  s(
    { trig = [[_6]], wordTrig = false },
    t('₆')
  ),
  s(
    { trig = [[_7]], wordTrig = false },
    t('₇')
  ),
  s(
    { trig = [[_8]], wordTrig = false },
    t('₈')
  ),
  s(
    { trig = [[_9]], wordTrig = false },
    t('₉')
  ),
  s(
    { trig = [[_a]], wordTrig = false },
    t('ₐ')
  ),
  s(
    { trig = [[_i]], wordTrig = false },
    t('ᵢ')
  ),
  s(
    { trig = [[_j]], wordTrig = false },
    t('ⱼ')
  ),
  s(
    { trig = [[_k]], wordTrig = false },
    t('ₖ')
  ),
  s(
    { trig = [[_m]], wordTrig = false },
    t('ₘ')
  ),
  s(
    { trig = [[_n]], wordTrig = false },
    t('ₙ')
  ),

  -- Lists
  s(
    { trig = [[.]], wordTrig = false },
    t('·')
  ),
  s(
    { trig = [[circ]], wordTrig = false },
    t('∘')
  ),

  -- Arrows
  s(
    { trig = [[d]], wordTrig = false },
    t('↓')
  ),
  s(
    { trig = [[l]], wordTrig = false },
    t('←')
  ),
  s(
    { trig = [[←r]], wordTrig = false },
    t('↔')
  ),
  s(
    { trig = [[r]], wordTrig = false },
    t('→')
  ),
  s(
    { trig = [[u]], wordTrig = false },
    t('↑')
  ),

  -- Greek letters
  s(
    { trig = [[a]], wordTrig = false },
    t('α')
  ),
  s(
    { trig = [[b]], wordTrig = false },
    t('β')
  ),
  s(
    { trig = [[g]], wordTrig = false },
    t('γ')
  ),
  s(
    { trig = [[e]], wordTrig = false },
    t('ε')
  ),
  s(
    { trig = [[pi]], wordTrig = false },
    t('π')
  ),
  s(
    { trig = [[s]], wordTrig = false },
    t('σ')
  ),
  s(
    { trig = [[z]], wordTrig = false },
    t('ζ')
  ),

  -- Other operators
  s(
    { trig = [[neg]], wordTrig = false },
    t('¬')
  ),
  s(
    { trig = [[αn]], wordTrig = false },
    t('∧')
  ),
  s(
    { trig = [[or]], wordTrig = false },
    t('∨')
  ),
  s(
    { trig = [[imp]], wordTrig = false },
    t('⇒')
  ),
  s(
    { trig = [[iff]], wordTrig = false },
    t('⇔')
  ),
  s(
    { trig = [[cap]], wordTrig = false },
    t('∩')
  ),
  s(
    { trig = [[cup]], wordTrig = false },
    t('∪')
  ),
}

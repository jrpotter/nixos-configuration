local M = {}

local cmp = require('cmp')
local cmp_buffer = require('cmp_buffer')
local luasnip = require("luasnip")

function M.setup()
  cmp.setup {
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    sources = {
      {
        name = 'nvim_lsp',
      },
      {
        name = 'buffer',
        option = {
          -- Complete only on visible buffers.
          get_bufnrs = function()
            local bufs = {}
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              bufs[vim.api.nvim_win_get_buf(win)] = true
            end
            return vim.tbl_keys(bufs)
          end
        },
      },
    },
    sorting = {
      comparators = {
        function (...)
          -- This also sorts completion results coming from other sources (e.g.
          -- LSPs).
          return cmp_buffer:compare_locality(...)
        end,
      },
    },
    mapping = {
      ['<c-n>'] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_next_item() else fallback() end
      end, { 'i', 's' }),

      ['<c-p>'] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.select_prev_item() else fallback() end
      end, { 'i', 's' }),

      ['<c-l>'] = cmp.mapping(function(fallback)
        if cmp.visible() then cmp.abort() else fallback() end
      end, { 'i', 's' }),

      ['<tab>'] = cmp.mapping(function(fallback)
        if cmp.get_active_entry() then
          cmp.confirm()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<s-tab>'] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
  }
end

return M

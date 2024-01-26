local M = {}

local cmp = require('cmp')
local cmp_buffer = require('cmp_buffer')
local luasnip = require('luasnip')
local types = require('cmp.types')

function M.setup()
  cmp.setup {
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    sources = {
      { name = 'luasnip', option = { show_autosnippets = true } },
      { name = 'nvim_lsp' },
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
        -- Prioritize snippets over other sources.
        function(entry1, entry2)
          local kind1 = entry1:get_kind()
          local kind2 = entry2:get_kind()
          if kind1 ~= kind2 then
            if kind1 == types.lsp.CompletionItemKind.Snippet then
              return true
            end
            if kind2 == types.lsp.CompletionItemKind.Snippet then
              return false
            end
          end
        end,
        function(...)
          -- This also sorts completion results coming from other sources.
          return cmp_buffer:compare_locality(...)
        end,
      },
    },
    mapping = {
      ['<tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<c-l>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<c-n>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<c-p>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
  }
end

return M

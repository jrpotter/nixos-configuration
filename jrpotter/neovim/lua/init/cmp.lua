local M = {}

local cmp = require('cmp')
local cmp_buffer = require('cmp_buffer')

function M.setup()
  cmp.setup {
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
        if cmp.visible() then cmp.confirm() else fallback() end
      end, { 'i', 's' }),
    },
  }
end

return M

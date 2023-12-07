local M = {}

local function set_telescope_map(key, picker)
  vim.keymap.set(
    'n',
    string.format('<c-;>%s', key),
    string.format('<cmd>Telescope %s<cr>', picker)
  )
  vim.keymap.set(
    'n',
    string.format('<c-;><c-%s>', key),
    string.format('<cmd>Telescope %s<cr>', picker)
  )
end

function M.setup()
  require('telescope').setup {
    defaults = {
      mappings = {
        i = {
          ['<c-s>'] = 'select_horizontal',
          ['<c-t>'] = 'select_tab',
          ['<c-v>'] = 'select_vertical',
          ['<esc>'] = 'close',
        },
      },
    },
    pickers = {
      buffers = { theme = 'ivy' },
      find_files = { theme = 'ivy' },
      live_grep = { theme = 'ivy' },
      lsp_definitions = { theme = 'cursor' },
      lsp_implementations = { theme = 'cursor' },
      lsp_type_definitions = { theme = 'cursor' },
      lsp_workspace_symbols = { theme = 'ivy' },
    },
  }

  -- General
  set_telescope_map(';', 'resume')
  set_telescope_map('b', 'buffers')
  set_telescope_map('f', 'find_files')
  set_telescope_map('g', 'live_grep')

  -- LSP
  set_telescope_map('?', 'diagnostics')
  set_telescope_map(']', 'lsp_definitions')
  set_telescope_map('i', 'lsp_implementations')
  set_telescope_map('s', 'lsp_workspace_symbols')
  set_telescope_map('t', 'lsp_type_definitions')

  vim.api.nvim_create_autocmd('User', {
    pattern = 'TelescopePreviewerLoaded',
    callback = function()
      vim.wo.wrap = true
    end,
  })
end

return M

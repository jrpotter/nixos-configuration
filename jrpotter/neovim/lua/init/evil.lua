-- Original configuration:
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require('lualine')

-- Color table for highlights
local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  blue     = '#51afef',
  red      = '#ec5f67',
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local config = {
  options = {
    -- Disable sections and component separators.
    component_separators = '',
    section_separators = '',
    theme = {
      -- We are going to use `lualine_c` an `lualine_x` as left and right
      -- sections.
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    -- These are to remove the defaults.
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later.
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- These are to remove the defaults.
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in `lualine_c` at left section.
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in `lualine_x` at right section.
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

-- Allow switching color based on the detected mode.
local function fg_by_mode()
  local mode_color = {
    n = colors.blue,
    i = colors.green,
    v = colors.red,
    [''] = colors.red,
    V = colors.red,
    c = colors.magenta,
    no = colors.blue,
    s = colors.orange,
    S = colors.orange,
    [''] = colors.orange,
    ic = colors.yellow,
    R = colors.violet,
    Rv = colors.violet,
    cv = colors.blue,
    ce = colors.blue,
    r = colors.cyan,
    rm = colors.cyan,
    ['r?'] = colors.cyan,
    ['!'] = colors.blue,
    t = colors.blue,
  }
  return { fg = mode_color[vim.fn.mode()] }
end

ins_left {
  function()
    return '▊'
  end,
  color = fg_by_mode,
  padding = { left = 0 },
}

ins_left {
  'filetype',
  cond = conditions.buffer_not_empty,
  icon_only = true,
  colored = false,
  color = fg_by_mode,
  padding = { left = 1, right = 1 },
}

ins_left {
  'filename',
  cond = conditions.buffer_not_empty,
  color = fg_by_mode,
}

ins_left {
  'filesize',
  cond = conditions.buffer_not_empty,
}

ins_left { '%c:%l/%L:%%%p', color = { fg = colors.fg, gui = 'bold' } }

ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ' },
  diagnostics_color = {
    color_error = { fg = colors.red },
    color_warn = { fg = colors.yellow },
    color_info = { fg = colors.cyan },
  },
}

-- Insert mid section. You can make any number of sections in neovim :)
ins_left {
  function()
    return '%='
  end,
}

-- Add first active LSP client.
local function get_active_lsp()
  local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
  local clients = vim.lsp.get_active_clients()
  if next(clients) == nil then
    return nil
  end
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      return client
    end
  end
  return nil
end

ins_left {
  function()
    local lsp_name = get_active_lsp().name
    local has_dap, dap = pcall(require, 'dap')
    if has_dap and dap.status() ~= "" then
      return string.format("%s:%s", lsp_name, dap.session().adapter.name)
    else
      return lsp_name
    end
  end,
  icon = ' ',
  color = { fg = '#ffffff', gui = 'bold' },
  cond = function()
    return get_active_lsp() ~= nil
  end
}

ins_left {
  function()
    return require('dap').status()
  end,
  icon = '🪲',
  color = { fg = '#DB7093', gui = 'bold' },
  cond = function()
    local has_dap, dap = pcall(require, 'dap')
    return has_dap and dap.status() ~= ""
  end,
}

-- Add components to right sections
ins_right {
  'o:encoding', -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = { fg = colors.green, gui = 'bold' },
}

ins_right {
  'fileformat',
  fmt = string.upper,
  icons_enabled = false,
  color = { fg = colors.green, gui = 'bold' },
}

ins_right {
  'branch',
  icon = '',
  color = { fg = colors.violet, gui = 'bold' },
}

ins_right {
  'diff',
  symbols = { added = ' ', modified = '柳', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
}

ins_right {
  function()
    return '▊'
  end,
  color = fg_by_mode,
  padding = { right = 0 },
}

lualine.setup(config)

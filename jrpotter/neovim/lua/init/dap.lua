local M = {}

local dap = require('dap')
local dap_ui = require('dap.ui')
local dap_ui_widgets = require('dap.ui.widgets')

local function query_launch()
  local command = vim.fn.input('Executable> ', vim.fn.getcwd() .. '/', 'file')
  vim.api.nvim_echo({ { '', 'None' } }, false, {})

  local parts = vim.split(command, '%s+', { trimempty = true })
  if not parts[1] then
    vim.api.nvim_err_writeln('Invalid command specification.')
    return
  end

  return parts[1], {unpack(parts, 2, #parts)}
end

-- Adaptation of https://github.com/mfussenegger/nvim-dap/blob/e154fdb6d70b3765d71f296e718b29d8b7026a63/lua/dap.lua#L413.
local function select_config_and_run()
  local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
  local configs = dap.configurations[filetype] or {}
  assert(
    vim.tbl_islist(configs),
    string.format(
      '`dap.configurations.%s` must be a list of configurations, got %s',
      filetype,
      vim.inspect(configs)
    )
  )
  if not configs[1] then
    local msg = 'No configuration found for `%s`. You need to add configs ' ..
        'to `dap.configurations.%s` (See `:h dap-configuration`)'
    vim.api.nvim_err_writeln(string.format(msg, filetype, filetype))
    return
  end

  local opts = {}
  opts.filetype = opts.filetype or filetype

  dap_ui.pick_if_many(
    configs,
    'Configuration: ',
    function(c)  -- Label function
      return c.name
    end,
    function(c)  -- Callback
      if not c then
        vim.api.nvim_err_writeln('No configuration selected.')
        return
      end
      local copy = vim.deepcopy(c)
      if copy.request == 'launch' then
        local program, args = query_launch()
        copy.program = program
        copy.args = args
      end
      dap.run(copy, opts)
    end
  )
end

local function sidebar_new(widget)
  return dap_ui_widgets.sidebar(widget, { width = 40 }, '')
end

local function sidebar_is_open(sidebar)
  return sidebar.win and vim.api.nvim_win_is_valid(sidebar.win)
end

-- Setup buffer-local DAP mappings. This function is expected to be called in
-- a filetype plugin, e.g. `nvim/after/ftplugin/c.lua`.
function M.buffer_map()
  local function set_nnoremap(key, func)
    vim.keymap.set(
      'n',
      string.format('<localleader>%s', key),
      func,
      { buffer = true }
    )
  end

  local sidebars = {
    expression = sidebar_new(dap_ui_widgets.expression),
    frames = sidebar_new(dap_ui_widgets.frames),
    scopes = sidebar_new(dap_ui_widgets.scopes),
    sessions = sidebar_new(dap_ui_widgets.sessions),
    threads = sidebar_new(dap_ui_widgets.threads),
  }

  local function any_sidebar_open()
    for _, sb in pairs(sidebars) do
      if sidebar_is_open(sb) then
        return true
      end
    end
    return false
  end

  local function toggle_sidebar(sidebar)
    if sidebar_is_open(sidebar) then
      sidebar.close({ mode = 'toggle' })
    else
      local win_id = vim.fn.win_getid()
      vim.cmd.wincmd('t')  -- Move to topleft-most window.
      vim.cmd(any_sidebar_open() and 'leftabove split' or 'vertical topleft split')
      sidebar.open()
      vim.fn.win_gotoid(win_id)
      -- Update state of windows.
      vim.api.nvim_win_set_option(sidebar.win, 'colorcolumn', '')
      vim.api.nvim_win_set_option(sidebar.win, 'list', false)
      vim.api.nvim_win_set_option(sidebar.win, 'wrap', false)
    end
  end

  set_nnoremap('<localleader>', select_config_and_run)
  set_nnoremap('b', dap.toggle_breakpoint)
  set_nnoremap('c', function()
    if dap.status() == '' then
      vim.api.nvim_err_writeln('No active session.')
      return
    end
    dap.continue()
  end)
  set_nnoremap('d', dap.down)
  set_nnoremap('i', dap.step_into)
  set_nnoremap('n', dap.step_over)
  set_nnoremap('o', dap.step_out)
  set_nnoremap('q', dap.close)
  set_nnoremap('r', dap.run_to_cursor)
  set_nnoremap('u', dap.up)
  set_nnoremap('x', dap.clear_breakpoints)
  set_nnoremap('we', function()
    toggle_sidebar(sidebars.expression)
  end)
  set_nnoremap('wf', function()
    toggle_sidebar(sidebars.frames)
  end)
  set_nnoremap('wc', function()
    toggle_sidebar(sidebars.scopes)
  end)
  set_nnoremap('wr', function()
    dap.repl.toggle({ height = 10 })
  end)
  set_nnoremap('ws', function()
    toggle_sidebar(sidebars.sessions)
  end)
  set_nnoremap('wt', function()
    toggle_sidebar(sidebars.threads)
  end)
  set_nnoremap('wx', function()
    for _, sb in pairs(sidebars) do
      if sidebar_is_open(sb) then
        toggle_sidebar(sb)
      end
      dap.repl.close()
    end
  end)
end

return M

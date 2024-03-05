local M = {}

local dap = require('dap')
local dap_ui = require('dap.ui')
local dap_ui_widgets = require('dap.ui.widgets')

local function query_launch()
  local command = vim.fn.input('Launch> ', vim.fn.getcwd() .. '/', 'file')
  vim.api.nvim_echo({ { '', 'None' } }, false, {})

  local parts = vim.split(command, '%s+', { trimempty = true })
  if not parts[1] then
    vim.api.nvim_err_writeln('Invalid command specification.')
    return
  end

  return parts[1], { unpack(parts, 2, #parts) }
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
    function(c) -- Label function
      return c.name
    end,
    function(c) -- Callback
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

-- Setup buffer-local DAP mappings. This function is expected to be called in
-- a filetype plugin, e.g. `nvim/after/ftplugin/c.lua`.
function M.buffer_map()
  local function sidebar_new(widget)
    return dap_ui_widgets.sidebar(widget, { width = 32 }, '')
  end

  local sidebars = {
    frames = sidebar_new(dap_ui_widgets.frames),
    scopes = sidebar_new(dap_ui_widgets.scopes),
    threads = sidebar_new(dap_ui_widgets.threads),
  }

  local function sidebar_is_open(sb)
    return sb.win and vim.api.nvim_win_is_valid(sb.win)
  end

  local function sidebar_any_open()
    for _, sb in pairs(sidebars) do
      if sidebar_is_open(sb) then
        return true
      end
    end
    return false
  end

  local function sidebar_toggle(sidebar)
    if sidebar_is_open(sidebar) then
      sidebar.close({ mode = 'toggle' })
    else
      local win_id = vim.fn.win_getid()
      vim.cmd.wincmd('t') -- Move to topleft-most window.
      vim.cmd(sidebar_any_open() and 'leftabove split' or 'vertical topleft split')
      sidebar.open()
      vim.fn.win_gotoid(win_id)
      -- Update state of windows.
      vim.api.nvim_win_set_option(sidebar.win, 'colorcolumn', '')
      vim.api.nvim_win_set_option(sidebar.win, 'list', false)
      vim.api.nvim_win_set_option(sidebar.win, 'wrap', false)
      vim.api.nvim_win_set_option(sidebar.win, 'winfixwidth', true)
    end
  end

  local function sidebar_only(sidebar)
    for _, sb in pairs(sidebars) do
      if sb ~= sidebar and sidebar_is_open(sb) then
        sb.close({ mode = 'toggle' })
      end
    end
    if not sidebar_is_open(sidebar) then
      sidebar_toggle(sidebar)
    end
  end

  local function find_bufnr_by_pattern(pattern)
    for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
      if vim.fn.bufname(bufnr):match(pattern) then
        return bufnr
      end
    end
    return nil
  end

  local function is_bufnr_open(bufnr)
    if not bufnr then
      return false
    end
    local windows = vim.fn.win_findbuf(bufnr)
    for _, _ in pairs(windows) do
      return true
    end
    return false
  end

  local function repl_is_open()
    return is_bufnr_open(find_bufnr_by_pattern("^%[dap%-repl]"))
  end

  local function term_is_open()
    return is_bufnr_open(find_bufnr_by_pattern("^%[dap%-terminal]"))
  end

  local function repl_open(opts)
    if repl_is_open() then
      return
    end
    local height = opts.height or 10
    local win_id = vim.fn.win_getid()
    vim.cmd.wincmd('b') -- Move to bottomright-most window.
    dap.repl.open({}, term_is_open() and
      'vertical rightbelow split' or
      string.format('rightbelow %dsplit', height))
    vim.api.nvim_win_set_option(0, 'winfixheight', true)
    vim.fn.win_gotoid(win_id)
  end

  local function term_open(opts)
    if term_is_open() then
      return
    end
    local height = opts.height or 10
    local win_id = vim.fn.win_getid()
    vim.cmd.wincmd('b') -- Move to bottomright-most window.
    vim.cmd(repl_is_open() and
      'vertical rightbelow split' or
      string.format('rightbelow %dsplit', height))
    vim.api.nvim_win_set_option(0, 'winfixheight', true)
    vim.api.nvim_win_set_buf(0, find_bufnr_by_pattern("^%[dap%-terminal]"))
    vim.fn.win_gotoid(win_id)
  end

  local function repl_close()
    dap.repl.close()
  end

  local function term_close()
    if not term_is_open() then
      return
    end
    local bufnr = find_bufnr_by_pattern("^%[dap%-terminal]")
    local windows = vim.fn.win_findbuf(bufnr)
    for _, win in pairs(windows) do
      vim.api.nvim_win_close(win, --[[force=]] true)
    end
  end

  local function repl_toggle(opts)
    if repl_is_open() then repl_close() else repl_open(opts) end
  end

  local function term_toggle(opts)
    if term_is_open() then term_close() else term_open(opts) end
  end

  local function set_nnoremap(key, func)
    local input = string.format('<localleader>%s', key)
    vim.keymap.set('n', input, func, { buffer = true })
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

  set_nnoremap('wf', function() sidebar_toggle(sidebars.frames) end)
  set_nnoremap('wh', function() sidebar_toggle(sidebars.threads) end)
  set_nnoremap('wr', function() repl_toggle({ height = 10 }) end)
  set_nnoremap('ws', function() sidebar_toggle(sidebars.scopes) end)
  set_nnoremap('wt', function() term_toggle({ height = 10 }) end)

  set_nnoremap('wF', function() sidebar_only(sidebars.frames) end)
  set_nnoremap('wH', function() sidebar_only(sidebars.threads) end)
  set_nnoremap('wR', function()
    term_close()
    repl_open({ height = 10 })
  end)
  set_nnoremap('wS', function() sidebar_only(sidebars.scopes) end)
  set_nnoremap('wT', function()
    repl_close()
    term_open({ height = 10 })
  end)
end

return M

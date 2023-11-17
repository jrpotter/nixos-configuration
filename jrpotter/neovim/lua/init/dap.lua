local M = {}

local function sidebar_new(widget)
  return require('dap.ui.widgets').sidebar(widget, { width = 40 }, '')
end

local function sidebar_is_open(sidebar)
  return sidebar.win and vim.api.nvim_win_is_valid(sidebar.win)
end

function M.buffer_map()
  local function set_nnoremap(key, func)
    vim.keymap.set(
      'n',
      string.format('<localleader>%s', key),
      func,
      { buffer = true }
    )
  end

  local dap = require('dap')
  local dap_ui_widgets = require('dap.ui.widgets')

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
    end
  end

  set_nnoremap('<localleader>', dap.continue)
  set_nnoremap('b', dap.toggle_breakpoint)
  set_nnoremap('n', dap.step_over)
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

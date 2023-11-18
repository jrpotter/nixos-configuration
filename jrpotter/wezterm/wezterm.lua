local wezterm = require('wezterm')

return {
  check_for_updates = false,
  keys = {
    {
      key = ' ',
      mods = 'LEADER|CTRL',
      action = wezterm.action.ShowLauncher,
    },
    {
      key = '"',
      mods = 'LEADER|SHIFT',
      action = wezterm.action.SplitVertical {
        domain = 'CurrentPaneDomain',
      },
    },
    {
      key = '%',
      mods = 'LEADER|SHIFT',
      action = wezterm.action.SplitHorizontal {
        domain = 'CurrentPaneDomain',
      },
    },
    {
      key = 'h',
      mods = 'LEADER',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
      key = 'j',
      mods = 'LEADER',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },
    {
      key = 'k',
      mods = 'LEADER',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(1),
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = wezterm.action.ActivateTabRelative(-1),
    },
    {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    {
      -- Disallow hiding the terminal from the keyboard.
      key = 'm',
      mods = 'CMD',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
    key = 'w',
      mods = 'LEADER',
      action = wezterm.action.ActivateKeyTable {
        name = 'resize_mode',
        one_shot = false,
        replace_current = true,
        until_unknown = true,
      },
    },
    {
      key = 'z',
      mods = 'LEADER',
      action = wezterm.action.TogglePaneZoomState,
    },
  },
  key_tables = {
    resize_mode = {
      {
        key = 'q',
        mods = 'NONE',
        action = wezterm.action.PopKeyTable,
      },
      {
        key = 'h',
        mods = 'NONE',
        action = wezterm.action.AdjustPaneSize { 'Left', 1 },
      },
      {
        key = 'j',
        mods = 'NONE',
        action = wezterm.action.AdjustPaneSize { 'Down', 1 },
      },
      {
        key = 'k',
        mods = 'NONE',
        action = wezterm.action.AdjustPaneSize { 'Up', 1 },
      },
      {
        key = 'l',
        mods = 'NONE',
        action = wezterm.action.AdjustPaneSize { 'Right', 1 },
      },
    },
  },
  leader = {
    key = ' ',
    mods = 'CTRL',
    timeout_milliseconds = 1500,
  },
}

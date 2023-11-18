local M = {}

local configs = require('nvim-treesitter.configs')

function M.setup()
  configs.setup {
    auto_install = false,
    highlight = { enable = true },
  }
end

return M

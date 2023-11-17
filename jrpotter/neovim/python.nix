{ pkgs, ... }:
let
  venv = pkgs.python3.withPackages (ps: with ps; [
    debugpy
    mccabe
    pycodestyle
    pyflakes
    python-lsp-server
    python-lsp-black
  ]);
in
{
  nvim-dap = ''
    local dap = require('dap')

    dap.adapters.python = function(callback, config)
      callback({
        name = 'debugpy',
        type = 'executable',
        command = '${venv}/bin/python3.10',
        args = { '-m', 'debugpy.adapter' },
        options = {
          source_filetype = 'python',
        },
      })
    end

    dap.configurations.python = dap.configurations.python or {}
    table.insert(dap.configurations.python, {
      name = 'Launch',
      type = 'python',
      request = 'launch',
      program = "''${file}",
      cwd = "''${workspaceFolder}",
    })
  '';

  nvim-lspconfig = ''
    require('lspconfig').pylsp.setup {
      settings = {
        pylsp = {
          -- `flake8` currently fails in some cases:
          -- https://github.com/python-lsp/python-lsp-server/pull/434
          configurationSources = 'pycodestyle',
          plugins = {
            autopep8 = { enabled = false },
            black = { enabled = true },
            mccabe = { enabled = true },
            pycodestyle = { enabled = true },
            pyflakes = { enabled = true },
            yapf = { enabled = false },
          },
        },
      },
    }
  '';

  extraPackages = [
    venv
  ];
}

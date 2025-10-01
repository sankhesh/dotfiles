-- nvim/plugins/debugging.lua
-- keep-sorted start block=yes

return {
  -- Core DAP Plugin
  {
    'mfussenegger/nvim-dap',
    -- Load dependencies, ensuring they are available when dap loads
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    -- Configuration runs when the plugin is loaded
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- --- DAP Listeners (for nvim-dap-ui integration) ---
      -- These automatically open and close the UI when a debug session starts/stops.
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      -- --- Sign Definitions for High Visibility ---
      -- 1. Define highlight groups for better contrast and visibility
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#FF0000', bold = true }) -- Bright Red
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#FFCC00', bold = true }) -- Bright Yellow/Gold
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#3A3A2C' }) -- Subtle line highlight

      -- 2. Redefine breakpoint symbol (Large circle '●')
      vim.fn.sign_define('DapBreakpoint', {
        text = '●',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })

      -- 3. Redefine stop symbol (Right arrow '▶' and line highlight)
      vim.fn.sign_define('DapStopped', {
        text = '▶',
        texthl = 'DapStopped',
        linehl = 'DapStoppedLine',
        numhl = 'DapStoppedLine',
      })

      -- NOTE: Keymaps and dap.configurations are now defined in the
      -- 'mason-nvim-dap.nvim' config block below to ensure proper load order.
    end,
  },

  -- DAP UI Plugin (Handles layout and display)
  {
    'rcarriga/nvim-dap-ui',
    -- This configures the UI layout.
    config = function()
      require('dapui').setup({
        icons = {
          expanded = '',
          collapsed = '',
          failed = '',
        },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.25 },
              { id = 'breakpoints', size = 0.25 },
              { id = 'stacks', size = 0.25 },
              { id = 'watches', size = 0.25 },
            },
            size = 40,
            position = 'left',
          },
          {
            elements = {
              { id = 'repl', size = 0.5 },
              { id = 'expressions', size = 0.5 },
            },
            size = 10,
            position = 'bottom',
          },
        },
        floating = {
          max_height = 0.9,
          max_width = 0.9,
        },
        windows = {
          elements = { 'scopes', 'breakpoints', 'stacks', 'watches', 'repl', 'expressions' },
        },
      })
    end,
  },

  -- Mason DAP Integration (Handles adapter installation and path configuration)
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    -- Set to false so this config runs early and registers the debug adapter before nvim-dap needs it.
    lazy = false,
    -- This configures the automatic detection and setup of debug adapters.
    config = function()
      local dap = require('dap')

      require('mason-nvim-dap').setup({
        ensure_installed = {
          'codelldb', -- Ensure codelldb is installed for C/C++/Rust
        },
        handlers = {
          -- FIX: Removed the generic '_' handler. We explicitly define the
          -- handler for codelldb to ensure it's set up correctly.
          codelldb = function(config)
            require('mason-nvim-dap').default_setup(config)
          end,
        },
      })

      -- --- Language-Specific Configurations (Defined AFTER Mason setup runs) ---
      dap.configurations.c = {
        {
          name = 'Launch',
          type = 'codelldb', -- This is now guaranteed to be registered
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
      dap.configurations.cpp = dap.configurations.c
      dap.configurations.rust = dap.configurations.c

      -- --- Keymaps (Defined AFTER Mason setup runs) ---
      local opts = { noremap = true, silent = true }

      -- Debugging functions (using <Leader>d as the prefix)
      vim.keymap.set(
        'n',
        '<Leader>dt',
        dap.toggle_breakpoint,
        vim.tbl_extend('force', opts, { desc = 'DAP: Toggle Breakpoint' })
      )
      vim.keymap.set(
        'n',
        '<Leader>dc',
        dap.continue,
        vim.tbl_extend('force', opts, { desc = 'DAP: Continue' })
      )
      vim.keymap.set(
        'n',
        '<Leader>dn',
        dap.step_over,
        vim.tbl_extend('force', opts, { desc = 'DAP: Step Over' })
      )
      vim.keymap.set(
        'n',
        '<Leader>di',
        dap.step_into,
        vim.tbl_extend('force', opts, { desc = 'DAP: Step Into' })
      )
      vim.keymap.set(
        'n',
        '<Leader>do',
        dap.step_out,
        vim.tbl_extend('force', opts, { desc = 'DAP: Step Out' })
      )
      vim.keymap.set(
        'n',
        '<Leader>dr',
        dap.repl.toggle,
        vim.tbl_extend('force', opts, { desc = 'DAP: Toggle REPL' })
      )
      vim.keymap.set(
        'n',
        '<Leader>ds',
        dap.session,
        vim.tbl_extend('force', opts, { desc = 'DAP: Session (status)' })
      )
      vim.keymap.set(
        'n',
        '<Leader>de',
        dap.run_last,
        vim.tbl_extend('force', opts, { desc = 'DAP: Run Last Config' })
      )

      -- DAP UI function
      local dapui = require('dapui')
      vim.keymap.set(
        'n',
        '<Leader>du',
        dapui.toggle,
        vim.tbl_extend('force', opts, { desc = 'DAP UI: Toggle UI' })
      ) -- Use require('dapui').toggle here

      -- Run/Launch configuration list
      vim.keymap.set('n', '<Leader>dl', function()
        dap.list_configs()
      end, vim.tbl_extend('force', opts, { desc = 'DAP: List Configurations' }))

      -- --- Diagnostic ---
      if dap.adapters.codelldb then
        print("DAP Adapter 'codelldb' is registered successfully.")
      else
        -- This should ideally never happen with this new load order
        print("DAP Adapter 'codelldb' is NOT registered. Check Mason installation.")
      end
    end,
  },

  -- Virtual Text (Shows variable values next to code while debugging)
  {
    'theHamsta/nvim-dap-virtual-text',
    opts = {},
  },

  -- nvim-nio (low-level dependency for DAP UI)
  {
    'nvim-neotest/nvim-nio',
    -- No config needed, it's a utility library
  },
}

-- lua/plugins/completion.lua

return {
  -- Autocompletion & LSP (Manual Setup)
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'clangd', 'pyright', 'ts_ls', 'cmake' },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local cmp_lsp = require('cmp_nvim_lsp')
      local capabilities = cmp_lsp.default_capabilities()

      -- Configure diagnostic popups globally to be non-focusable
      vim.diagnostic.config({
        float = {
          focusable = false,
          focus = false, -- Explicitly ensure it never gets focus
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      })

      -- Globally override the hover handler to make the window non-focusable
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
        focusable = false,
        focus = false, -- Explicitly ensure it never gets focus
      })

      -- Add highlight groups for gray floating windows
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#3c3836' }) -- Using a gray background
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#3c3836' }) -- Using a gray background

      -- Flag to prevent CursorHold after explicit 'K' press
      vim.g.lsp_hover_k_pressed = false

      local on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { buffer = bufnr, remap = false }

        -- Your custom keymaps
        keymap('n', 'gd', function()
          vim.lsp.buf.definition()
        end, opts)
        keymap('n', 'gD', function()
          vim.lsp.buf.declaration()
        end, opts)
        keymap('n', 'gi', function()
          vim.lsp.buf.implementation()
        end, opts)
        -- Modified K keymap to set the flag
        keymap('n', 'K', function()
          vim.g.lsp_hover_k_pressed = true -- Set flag when K is pressed
          vim.lsp.buf.hover()
        end, opts)
        keymap('n', '<leader>ws', function()
          vim.lsp.buf.workspace_symbol()
        end, opts)
        keymap('n', '<leader>vd', function()
          vim.diagnostic.open_float()
        end, opts)
        keymap('n', ']d', function()
          vim.diagnostic.goto_next()
        end, opts)
        keymap('n', '[d', function()
          vim.diagnostic.goto_prev()
        end, opts)
        keymap('n', '<leader>ca', function()
          vim.lsp.buf.code_action()
        end, opts)
        keymap('n', '<leader>rf', function()
          vim.lsp.buf.references()
        end, opts)
        keymap('n', '<leader>rn', function()
          vim.lsp.buf.rename()
        end, opts)
        keymap('i', '<C-h>', function()
          vim.lsp.buf.signature_help()
        end, opts)
        keymap('n', '<leader>ih', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, { desc = 'Toggle Inlay Hints' })

        if client.supports_method('textDocument/inlayHint') then
          vim.lsp.inlay_hint.enable(true)
        end

        -- Autocommand to reset flag on cursor move
        vim.api.nvim_create_autocmd('CursorMoved', {
          buffer = bufnr,
          callback = function()
            vim.g.lsp_hover_k_pressed = false -- Reset flag when cursor moves
          end,
        })

        -- Autocommand for automatic hover documentation
        vim.api.nvim_create_autocmd('CursorHold', {
          buffer = bufnr,
          callback = function()
            if vim.api.nvim_get_mode().mode == 'n' then
              -- Only trigger CursorHold hover if K was not just pressed
              if vim.g.lsp_hover_k_pressed then
                vim.g.lsp_hover_k_pressed = false -- Consume the flag
                return -- Skip this CursorHold event
              end

              local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.fn.line('.') - 1 })
              if #diagnostics > 0 then
                vim.diagnostic.open_float(nil, { scope = 'line' })
              else
                vim.lsp.buf.hover()
              end
            end
          end,
        })
      end
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      -- 'milanglacier/minuet-ai.nvim',
    },
    config = function()
      local cmp = require('cmp')
      -- local minuet = require('minuet')

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          -- ['<A-y>'] = minuet.make_cmp_map(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          -- { name = 'minuet' },
        }),
        performance = {
          -- It is recommended to increase the timeout duration due to
          -- the typically slower response speed of LLMs compared to
          -- other completion sources. This is not needed when you only
          -- need manual completion.
          fetching_timeout = 300,
        },
      })
    end,
  },
  -- {
  --   'milanglacier/minuet-ai.nvim',
  --   config = function()
  --     local minuet = require('minuet')
  --     minuet.setup({
  --       provider = 'gemini',
  --       provider_options = {
  --         gemini = {
  --           model = 'gemini-2.5-flash',
  --         },
  --       },
  --       virtualtext = {
  --         auto_trigger_ft = {},
  --         -- Manual keymap for minuet-ai: <A-Space>
  --         keymap = {
  --           -- accept whole completion
  --           accept = '<A-a>',
  --           -- accept one line
  --           accept_line = '<A-l>',
  --           -- accept n lines (prompts for number)
  --           -- e.g. "A-z 2 CR" will accept 2 lines
  --           accept_n_lines = '<A-z>',
  --           -- Cycle to prev completion item, or manually invoke completion
  --           prev = '<A-[>',
  --           -- Cycle to next completion item, or manually invoke completion
  --           next = '<A-]>',
  --           dismiss = '<A-e>',
  --         },
  --       },
  --     })
  --   end,
  -- },
}

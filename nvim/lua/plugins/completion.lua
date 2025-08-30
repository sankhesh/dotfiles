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
      local lspconfig = require('lspconfig')
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

      -- Setup servers based on what is installed by mason-lspconfig
      local servers = require('mason-lspconfig').get_installed_servers()
      for _, server_name in ipairs(servers) do
        local server_opts = {
          on_attach = on_attach,
          capabilities = capabilities,
        }

        -- Add custom logic for clangd to handle project-specific configs
        if server_name == 'clangd' then
          local root_dir = require('lspconfig.util').find_git_ancestor(vim.api.nvim_buf_get_name(0))
          if root_dir then
            local clangd_config_exists = vim.loop.fs_stat(root_dir .. '/.clangd')

            if not clangd_config_exists then
              server_opts.cmd = {
                'clangd',
                '--compile-commands-dir=../bld',
              }
            end
          end
        end
        lspconfig[server_name].setup(server_opts)
      end
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
}

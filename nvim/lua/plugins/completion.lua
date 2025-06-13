-- lua/plugins/completion.lua

return {
  -- Add Codeium plugin
  { 'Exafunction/windsurf.vim', event = 'BufEnter' },
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
        ensure_installed = { 'clangd', 'pyright', 'tsserver', 'cmake' },
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

      local on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { buffer = bufnr, remap = false }

        keymap('n', 'gd', function()
          vim.lsp.buf.definition()
        end, opts)
        keymap('n', 'gD', function()
          vim.lsp.buf.declaration()
        end, opts)
        keymap('n', 'gi', function()
          vim.lsp.buf.implementation()
        end, opts)
        keymap('n', 'K', function()
          vim.lsp.buf.hover()
        end, opts)
        keymap('n', '<leader>ws', function()
          vim.lsp.buf.workspace_symbol()
        end, opts)
        keymap('n', '<leader>vd', function()
          vim.diagnostic.open_float()
        end, opts)
        keymap('n', '[d', function()
          vim.diagnostic.goto_next()
        end, opts)
        keymap('n', ']d', function()
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
      end

      -- Setup servers based on what is installed by mason-lspconfig
      local servers = require('mason-lspconfig').get_installed_servers()
      for _, server_name in ipairs(servers) do
        local server_opts = {
          on_attach = on_attach,
          capabilities = capabilities,
        }

        -- Add specific configuration for clangd
        if server_name == 'clangd' then
          server_opts.cmd = {
            'clangd',
            '--compile-commands-dir=../bld', -- Point to the build directory
          }
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
  { 'L3MON4D3/LuaSnip', dependencies = { 'rafamadriz/friendly-snippets' } },
}

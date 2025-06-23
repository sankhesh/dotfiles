-- lua/plugins/init.lua

return {
  -- NOTE: This file is the main plugin entry point.
  -- `lazy.nvim` will automatically load all other files in this directory.
  -- You can add any plugins that don't need their own file here.

  -- Utility plugins
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'junegunn/goyo.vim',
  'Exafunction/windsurf.vim',

  -- Diffchanges plugin from original vimrc
  {
    'vim-scripts/diffchanges.vim',
    config = function()
      if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
        vim.g.diffchanges_patch_cmd = 'FC'
      end
    end,
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Formatting and Linting
  {
    'stevearc/conform.nvim',
    opts = {
      -- Add custom options for specific formatters
      formatters = {
        ['cmake-format'] = {
          args = {
            '--dangle-align=child',
            '--dangle-parens=true',
            '--enable-sort=true',
            '--max-subgroups-hwrap=2',
            '--line-width=80',
          },
        },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        python = { 'isort', 'black' },
        javascript = { { 'prettierd', 'prettier' } },
        cmake = { 'cmake-format' },
        ['*'] = { 'remove_trailing_lines', 'trim_whitespace' }, -- Apply to all file types
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        python = { 'flake8' },
        cmake = { 'cmakelint' },
      }

      lint.linters.cmakelint.args = {
        '--filter=-whitespace/extra,-whitespace/indent',
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}

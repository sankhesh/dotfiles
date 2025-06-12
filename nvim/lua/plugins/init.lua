-- lua/plugins/init.lua

return {
  -- NOTE: This file is the main plugin entry point.
  -- `lazy.nvim` will automatically load all other files in this directory.
  -- You can add any plugins that don't need their own file here.

  -- Utility plugins
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'junegunn/goyo.vim',

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
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        python = { 'isort', 'black' },
        javascript = { { 'prettierd', 'prettier' } },
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
        require('lint').linters_by_ft = {
            python = {'flake8'}
        }
        vim.api.nvim_create_autocmd({"BufWritePost", "BufEnter", "InsertLeave"}, {
            callback = function()
                require("lint").try_lint()
            end
        })
    end
  },
}

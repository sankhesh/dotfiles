-- lua/plugins/conform.lua

return {
  'stevearc/conform.nvim',
  event = { 'LspAttach', 'BufReadPost', 'BufNewFile' },
  opts = {
    log_level = vim.log.levels.DEBUG,
    -- Add custom options for specific formatters
    formatters = {
      cmake_format = {
        prepend_args = {
          '--dangle-align=prefix',
          '--dangle-parens=false',
          '--enable-sort=true',
          '--max-subgroups-hwrap=3',
          '--max-pargs-hwrap=3',
          '--line-width=100',
          '--tab-size=2',
        },
      },
      -- clang_format = {
      --   -- Use the default clang-format configuration file if it exists
      --   config_file = vim.fn.findfile('.clang-format', '.;') or nil,
      --   -- Fallback to a specific style if no config file is found
      --   fallback_style = 'mozilla',
      -- },
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      objcpp = { 'clang_format' },
      python = { 'isort', 'black', 'autopep8', 'autoflake' },
      javascript = { 'prettierd', 'prettier', 'eslint' },
      typescript = { 'eslint' },
      typescriptreact = { 'eslint' },
      json = { 'prettierd', 'prettier' },
      cmake = { 'cmake_format' },
      ['*'] = { 'trim_whitespace' }, -- Apply to all file types
    },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat then
        return
      end
      return {
        timeout_ms = 2500,
        lsp_fallback = true,
        async = false,
      }
    end,
  },
  config = function(_, opts)
    local conform = require('conform')

    -- Setup conform.nvim to work
    conform.setup(opts)

    -- Customize the default prettier command
    conform.formatters.prettier = {
      prepend_args = { '--prose-wrap', 'always' },
    }

    vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 2500,
      })
    end, { desc = 'Format file or range (in visual mode)' })

    vim.keymap.set(
      { 'n' },
      '<leader>af',
      ':lua vim.g.disable_autoformat = not vim.g.disable_autoformat<CR>',
      { desc = 'Toggle autoformat' }
    )
  end,
}

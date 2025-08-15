-- lua/plugins/conform.lua

return {
    'stevearc/conform.nvim',
    event = { "LspAttach", "BufReadPost", "BufNewFile" },
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
        javascript = { 'prettierd', 'prettier', 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        cmake = { 'cmake_format' },
        ['*'] = { 'trim_whitespace' }, -- Apply to all file types
      },
      format_after_save = {
        timeout_ms = 2500, -- Increased timeout from 500 to 2500ms (2.5 seconds)
        lsp_fallback = true,
        async = true,
      },
    },
  config = function (_, opts)
    local conform = require ("conform")

    -- Setup conform.nvim to work
    conform.setup(opts)

    -- Customize the default prettier command
    conform.formatters.prettier = {
      prepend_args = { "--prose-wrap", "always" },
    }
  end,
}

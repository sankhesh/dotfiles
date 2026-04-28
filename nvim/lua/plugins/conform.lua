-- lua/plugins/conform.lua

return {
  'stevearc/conform.nvim',
  event = { 'LspAttach', 'BufReadPost', 'BufNewFile' },
  opts = {
    log_level = vim.log.levels.WARN,
    -- Add custom options for specific formatters
    formatters = {
      cmake_format = {
        prepend_args = {
          '--dangle-align=prefix',
          '--dangle-parens=true',
          '--enable-sort=false',
          '--max-subgroups-hwrap=3',
          '--max-pargs-hwrap=1',
          '--line-width=100',
          '--tab-size=2',
          '--keyword-case=lower',
          '--command-case=lower',
        },
      },
      clang_format = {
        args = function(self, ctx)
          -- Project-specific .clang-format (including ~/.clang-format) takes
          -- precedence via clang-format's normal auto-discovery.
          if vim.fn.findfile('.clang-format', ctx.dirname .. ';') ~= '' then
            return { '--assume-filename', '$FILENAME' }
          end
          -- No config found anywhere in the hierarchy: apply VTK-derived style.
          -- StatementMacros are omitted here; add them to ~/.clang-format instead.
          local vtk_style = '{BasedOnStyle: Mozilla, AlignAfterOpenBracket: DontAlign,'
            .. ' AlignOperands: false, AlwaysBreakAfterReturnType: None,'
            .. ' AlwaysBreakAfterDefinitionReturnType: None,'
            .. ' BreakBeforeBraces: Allman, BinPackArguments: true,'
            .. ' BinPackParameters: true, ColumnLimit: 100,'
            .. ' SpaceAfterTemplateKeyword: true, Standard: c++17}'
          return { '--style=' .. vtk_style, '--assume-filename', '$FILENAME' }
        end,
      },
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
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
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

    vim.keymap.set({ 'n' }, '<leader>af', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
    end, { desc = 'Toggle autoformat' })

    -- Disable autoformat for CMake files by default
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'cmake',
      callback = function()
        vim.b.disable_autoformat = true
      end,
      desc = 'Disable autoformat for CMake files',
    })
  end,
}

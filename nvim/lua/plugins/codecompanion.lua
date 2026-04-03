-- lua/plugins/codecompanion.lua

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'folke/snacks.nvim',
  },
  config = function()
    require('codecompanion').setup({
      strategies = {
        chat = {
          adapter = 'claude_code',
          model = 'opus',
          -- adapter = 'gemini',
          -- model = 'gemini-2.5-pro',
        },
        inline = {
          adapter = 'copilot',
          model = 'gemini-3.1-pro',
        },
      },
      adapters = {
        acp = {
          claude_code = function()
            local home = vim.fn.expand('~')
            local file_path = vim.fn.fnamemodify(home .. '/.claude_code_apitoken', ':p')

            -- Read the token directly using Lua instead of shell commands
            local token = ''
            local f = io.open(file_path, 'r')
            if f then
              -- Read entire file and trim any whitespace/newlines
              token = f:read('*a'):gsub('%s+', '')
              f:close()
            else
              vim.notify('Could not find Claude Code token at ' .. file_path, vim.log.levels.WARN)
            end

            return require('codecompanion.adapters').extend('claude_code', {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = token,
              },
            })
          end,
        },
      },
    })

    vim.keymap.set(
      { 'n', 'v' },
      '<leader>a',
      '<cmd>CodeCompanionActions<cr>',
      { noremap = true, silent = true, desc = 'Code Companion Actions' }
    )
    vim.keymap.set(
      'n',
      '<leader>c',
      '<cmd>CodeCompanionChat Toggle<cr>',
      { noremap = true, silent = true, desc = 'Code Companion Chat' }
    )
    vim.keymap.set(
      'v',
      '<leader>c',
      '<cmd>CodeCompanionChat Add<cr>',
      { noremap = true, silent = true, desc = 'Add selected text to the chat buffer' }
    )
  end,
}

-- lua/plugins/codecompanion.lua

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    log_level = 'DEBUG',
  },
  config = function()
    require('codecompanion').setup({
      strategies = {
        chat = {
          -- adapter = 'copilot',
          -- model = 'gpt-4.1',
          adapter = 'gemini',
          model = 'gemini-2.5-pro',
        },
      },
      inline = {
        -- adapter = 'copilot',
        -- model = 'gpt-4.1',
        adapter = 'gemini',
        model = 'gemini-2.5-pro',
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

-- filepath: ~/.config/nvim/lua/plugins/telescope-tabs.lua
-- Telescope-tabs configuration for Neovim

-- Ensure telescope.nvim is loaded first
return {
  'LukasPietzschmann/telescope-tabs',
  config = function()
    require('telescope').load_extension('telescope-tabs')
    require('telescope-tabs').setup({
      -- Your custom config :^)
      show_preview = true,
      close_tab_shortcut = '<C-d>',
    })
    -- Map <C-Space> to open telescope-tabs picker in normal mode
    vim.keymap.set(
      'n',
      '<C-Space>',
      '<cmd>Telescope telescope-tabs list_tabs<CR>',
      { desc = 'Telescope Tabs Picker' }
    )
  end,
  dependencies = { 'nvim-telescope/telescope.nvim' },
}

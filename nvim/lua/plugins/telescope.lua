-- lua/plugins/telescope.lua

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          previewer = 'catppuccinopopup',
          path_display = { 'truncate' },
        },
      })
    end,
  },
}

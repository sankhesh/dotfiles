-- lua/plugins/ui.lua

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          icons_enabled = true,
        },
      })
    end,
  },
  {
    'ms-jpq/chadtree',
    build = 'python3 -m chadtree deps',
    config = function()
      -- Optional chadtree configuration can go here
    end
  },
  { 'andymass/vim-matchup' },
  {
    "akinsho/bufferline.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    version = "*",
    opts = {}
  },
}

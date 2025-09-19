-- lua/plugins/init.lua

return {
  -- NOTE: This file is the main plugin entry point.
  -- `lazy.nvim` will automatically load all other files in this directory.
  -- You can add any plugins that don't need their own file here.

  -- Utility plugins
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'junegunn/goyo.vim',

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
}

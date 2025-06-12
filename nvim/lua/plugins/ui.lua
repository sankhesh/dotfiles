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
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff' },
          lualine_c = {
            'filename',
            {
              -- Add the Codeium status component
              function()
                -- Check if the function exists before calling it
                if vim.fn.exists('*codeium#GetStatusString') == 1 then
                  return vim.fn['codeium#GetStatusString']()
                else
                  return ''
                end
              end,
              color = { fg = '#98c379' }, -- Optional: set a color for the status
            },
          },
          lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      })
    end,
  },
  {
    'ms-jpq/chadtree',
    build = 'python3 -m chadtree deps',
    config = function()
      -- Optional chadtree configuration can go here
    end,
  },
  { 'andymass/vim-matchup' },
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    version = '*',
    opts = {},
  },
}

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
    opts = {
      options = {
        mode = 'tabs',
        separator_style = 'thin',
        show_buffer_close_icons = false,
        show_close_icon = true,
        color_icons = true,
        numbers = 'buffer_id | ordinal',
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          if context.buffer:current() then
            return ''
          end
          local icon = level:match('error') and ' ' or ' '
          return ' ' .. icon .. count
        end,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' },
        },
      },
    },
  },
}

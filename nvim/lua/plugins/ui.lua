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
  { 'tiagovla/scope.nvim', config = true },
  {
    'folke/noice.nvim',
    event = 'VeryLazy', -- Load late to ensure other plugins are ready
    dependencies = {
      { 'rcarriga/nvim-notify' },
    },
    config = function()
      require('noice').setup({
        cmdline = {
          enabled = true, -- enables the Noice cmdline UI
          view = 'cmdline_popup', -- view for cmdline UI
          opts = {}, -- options for the cmdline UI
        },
        messages = {
          enabled = true, -- enables the Noice messages UI
          view = 'notify', -- view for messages
          opts = {}, -- options for view
        },
        popupmenu = {
          enabled = true, -- enables the Noice popupmenu UI
          view = 'cmp_menu', -- Changed to 'cmp_menu' to integrate with nvim-cmp for tab completion
          opts = {}, -- options for view
        },
        routes = {
          {
            filter = {
              event = 'msg_show',
              kind = '',
              find = 'No information available',
            },
            opts = { skip = true },
          },
        },
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- noice can be used for inc-rename. search for help on `:help noice.inc_rename`
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        silent = true, -- Set to true to suppress messages from being printed to the cmdline
      })
    end,
  },
}

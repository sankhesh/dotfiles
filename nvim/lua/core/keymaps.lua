-- lua/core/keymaps.lua

local keymap = vim.keymap.set

-- Custom function to switch between header and source files
local function switch_header_source()
  local current_file = vim.fn.expand('%:p')
  local basename = vim.fn.fnamemodify(current_file, ':r')
  local extension = vim.fn.fnamemodify(current_file, ':e')

  -- Define possible alternate extensions
  local header_exts = { 'h', 'hpp', 'hh' }
  local source_exts = { 'c', 'cpp', 'cxx', 'cc' }

  local is_header = vim.tbl_contains(header_exts, extension)
  local is_source = vim.tbl_contains(source_exts, extension)

  local alternate_file_found = false

  if is_header then
    for _, ext in ipairs(source_exts) do
      local alternate = basename .. '.' .. ext
      if vim.fn.filereadable(alternate) == 1 then
        vim.cmd.vsplit(alternate)
        alternate_file_found = true
        break
      end
    end
  elseif is_source then
    for _, ext in ipairs(header_exts) do
      local alternate = basename .. '.' .. ext
      if vim.fn.filereadable(alternate) == 1 then
        vim.cmd.vsplit(alternate)
        alternate_file_found = true
        break
      end
    end
  end

  if not alternate_file_found then
    print('No alternate file found.')
  end
end

-- File explorer
keymap('n', '<leader>e', ':CHADopen<CR>', { desc = 'Toggle file explorer (CHADTree)' })

-- Telescope (fuzzy finding)
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
keymap('n', '<leader>fr', '<cmd>Telescope resume<cr>', { desc = 'Resume previous find' })
keymap('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', { desc = 'Go to definition' })
keymap('n', 'grr', '<cmd>Telescope lsp_references<cr>', { desc = 'List references' })

-- Git
keymap('n', '<leader>gg', ':Neogit<CR>', { desc = 'Open Neogit' })
keymap('n', '<leader>gl', ':Neogit log --all --graph<CR>', { desc = 'View git log graph' })

-- Diffview keymaps
keymap('n', '<leader>dv', ':DiffviewOpen<CR>', { desc = 'Open Diffview' })
keymap('n', '<leader>dc', ':DiffviewClose<CR>', { desc = 'Close Diffview' })
keymap('n', '<leader>dh', ':DiffviewFileHistory<CR>', { desc = 'Diffview file history' })

-- Diffchanges
keymap('n', '<leader>p', ':DiffChangesPatchToggle<CR>', { desc = 'Diff changes patch' })
keymap('n', '<leader>f', ':DiffChangesDiffToggle<CR>', { desc = 'Diff changes diff' })

-- Goyo
keymap('n', '<leader>gy', ':Goyo<CR>', { desc = 'Toggle Goyo (distraction-free)' })

-- Cycle through buffers
keymap('n', '<S-l>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
keymap('n', '<S-h>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })

-- Switch between header and source
keymap('n', '<leader>s', switch_header_source, { desc = 'Switch Header/Source' })

-- Select Session
keymap('n', '<leader>ps', ':SessionSelect<CR>', { desc = 'Select Session' })

if vim.g.neovide == true then
  vim.api.nvim_set_keymap(
    'n',
    '<C-_>',
    ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.05<CR>',
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<C-->',
    ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.05<CR>',
    { silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<C-0>',
    ':lua vim.g.neovide_scale_factor = 1<CR>',
    { silent = true }
  )
end

-- Editor Toggles
keymap('n', '<leader>l', ':set list!<CR>', { desc = 'Toggle list chars' })

-- lua/core/keymaps.lua

local keymap = vim.keymap.set

-- File explorer
keymap('n', '<leader>e', ':CHADopen<CR>', { desc = 'Toggle file explorer (CHADTree)' })

-- Telescope (fuzzy finding)
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })

-- Git
keymap('n', '<leader>gg', ':Neogit<CR>', { desc = 'Open Neogit' })

-- Formatting
keymap({ 'n', 'v' }, '<leader>cf', function()
  require('conform').format({ async = true, lsp_fallback = true })
end, { desc = 'Format code' })

-- Goyo
keymap('n', '<leader>gy', ':Goyo<CR>', { desc = 'Toggle Goyo (distraction-free)' })

-- Cycle through buffers
keymap('n', '<S-l>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
keymap('n', '<S-h>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })

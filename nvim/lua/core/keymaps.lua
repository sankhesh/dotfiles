-- lua/core/keymaps.lua

local keymap = vim.keymap.set

-- File explorer
keymap(
  'n',
  '<leader>e',
  ':NvimTreeFindFileToggle<CR>',
  { desc = 'Toggle file explorer (Nvim-Tree)' }
)

-- Telescope (fuzzy finding)
keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
keymap('n', '<leader>fr', '<cmd>Telescope resume<cr>', { desc = 'Resume previous find' })
keymap('n', 'grr', '<cmd>Telescope lsp_references<cr>', { desc = 'List references' })

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

-- Switch between header and source (uses clangd)
keymap('n', '<leader>s', '<cmd>ClangdSwitchSourceHeader<cr>', { desc = 'Switch Header/Source' })

-- Select Session
keymap('n', '<leader>ps', ':Persisted select<CR>', { desc = 'Select Session' })

if vim.g.neovide then
  keymap('n', '<C-_>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.05
  end, { silent = true, desc = 'Neovide: Zoom in' })
  keymap('n', '<C-->', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.05
  end, { silent = true, desc = 'Neovide: Zoom out' })
  keymap('n', '<C-0>', function()
    vim.g.neovide_scale_factor = 1
  end, { silent = true, desc = 'Neovide: Reset zoom' })
end

-- Editor Toggles
keymap('n', '<leader>l', ':set list!<CR>', { desc = 'Toggle list chars' })

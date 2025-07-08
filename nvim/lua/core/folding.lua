-- lua/core/folding.lua

local M = {} -- Create a module table

-- General folding options
vim.opt.foldenable = true
vim.opt.foldopen = 'block,insert,jump,mark,percent,quickfix,search,tag,undo'

-- Folds with a level > foldlevel will be closed
-- Setting 0 will close all folds
-- Setting 99 ensures folds are open by default
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = -1
vim.opt.foldnestmax = 5 -- Only fold up to this many nested levels.
vim.opt.foldminlines = 1 -- Only fold if there are at least this many lines.
vim.opt.fillchars = {
  fold = '·',
  foldopen = '',
  foldclose = '',
}

-- Custom foldtext function in Lua
-- This function is called by 'foldtext' option to display folded lines.
-- It's now part of the 'M' module table to be accessible via require().
M.MyFoldText = function()
  local line = vim.fn.getline(vim.v.foldstart)
  local numberOfLines = 1 + vim.v.foldend - vim.v.foldstart
  -- Remove fold markers (/\* \*/ {{{d=) from the line
  local sub = string.gsub(line, '/%*|%*/|%{%{%{%d*=', '')
  -- Return the formatted fold text
  return vim.v.folddashes .. sub .. ' (' .. numberOfLines .. ' Lines)'
end

-- Treesitter folding (recommended for Neovim)
-- This sets the fold method to 'expr' and uses the Treesitter fold expression.
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- Reference the Lua function using v:lua.require('module_name').function_name()
vim.opt.foldtext = 'v:lua.require("core.folding").MyFoldText()'

-- Keymap for toggling folds (alias for 'za')
vim.keymap.set('n', 'zz', 'za', { silent = true, desc = 'Toggle fold under cursor' })

-- Highlight group definitions for folds and sign column
-- These can also be managed by your colorscheme, but are included for direct translation.
vim.api.nvim_set_hl(
  0,
  'Folded',
  { fg = '#00FFFF', bg = '#303030', underline = true, undercurl = true, sp = '#008080' }
)
vim.api.nvim_set_hl(0, 'SignColumn', { fg = '#00FFFF', bg = '#1C1C1C' })
vim.api.nvim_set_hl(0, 'LineNr', { fg = '#FFFF00', bg = '#1C1C1C' })

return M -- Return the module table

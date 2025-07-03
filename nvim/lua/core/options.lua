-- lua/core/options.lua

-- General options
vim.opt.number = true

vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmatch = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', eol = '¬', trail = '·', space = '·' }
vim.opt.inccommand = 'split'
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.laststatus = 3 -- Global statusline

-- Highlight current line and add cursor column
vim.opt.cursorline = true -- This highlights the current line
vim.opt.colorcolumn = '100' -- This adds a column at the 100th character

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

-- Session
vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'globals' }

if vim.g.neovide then
  -- neovide specific options here
  vim.opt.guifont = 'CaskaydiaCove Nerd Font:h10'
end

-- init.lua

-- Set leader key
vim.g.mapleader = ","

-- Load core configuration
require("core.options")
require("core.keymaps")

-- Bootstrap lazy.nvim and load plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugin specifications and enable LuaRocks support
require("lazy").setup("plugins", {
  rocks = {
    -- Enable lazy.nvim to manage LuaRocks dependencies for plugins
    enabled = true,
  },
})

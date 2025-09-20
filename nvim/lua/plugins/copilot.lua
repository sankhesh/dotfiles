-- lua/plugins/copilot.lua

return {
  'github/copilot.vim',
  lazy = false,
  config = function()
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ''
  end,
}

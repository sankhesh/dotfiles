-- lua/plugins/colorscheme.lua

return {
  {
    'Mofiqul/vscode.nvim',
    priority = 1000, -- Ensure it loads first
    config = function()
      require('vscode').setup({
        -- You can add any specific configuration options here
        -- For example:
        -- styles = {
        --   comments = "italic",
        --   keywords = "bold",
        -- }
      })
      vim.cmd("colorscheme vscode")
    end
  },
}


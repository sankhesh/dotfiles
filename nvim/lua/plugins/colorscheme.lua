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
        -- Enable transparent background
        transparent = true,

        -- Enable italic comment
        italic_comments = true,

        -- Underline `@markup.link.*` variants
        underline_links = true,

        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,

        -- Apply theme colors to terminal
        terminal_colors = true,
      })
      vim.cmd("colorscheme vscode")
    end
  },
}


-- lua/plugins/treesitter.lua

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'c',
          'cpp',
          'lua',
          'vim',
          'vimdoc',
          'python',
          'javascript',
          'typescript',
          'html',
          'css',
          'markdown',
          'bash',
          'json',
          'yaml',
          'cmake',
        },
        sync_install = true,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
        indent = { enable = true },
      })
    end,
  },
}

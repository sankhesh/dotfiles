-- lua/plugins/treesitter.lua

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    main = 'nvim-treesitter.config',
    config = function()
      require('nvim-treesitter.config').setup({
        ensure_installed = {
          'bash',
          'c',
          'cmake',
          'cpp',
          'css',
          'html',
          'javascript',
          'json',
          'lua',
          'markdown',
          'python',
          'regex',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}

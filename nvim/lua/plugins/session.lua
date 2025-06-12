-- lua/plugins/session.lua

return {
  {
    'olimorris/persisted.nvim',
    lazy = false, -- Load this plugin on startup
    config = function()
      require('persisted').setup({
        -- Enable autostarting sessions
        autosave = true,
        autostart = true,
        autoload = true,
        on_autoload_no_session = function()
          vim.notify('No existing session to load.')
        end,
        use_git_branch = true,

        -- Other options can be added here, for example:
        save_dir = vim.fn.stdpath('config') .. '/sessions/', -- Change save directory
        on_load = function()
          print('Session loaded!')
        end,
      })
    end,
  },
}

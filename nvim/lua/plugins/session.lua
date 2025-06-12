-- lua/plugins/session.lua

return {
  {
    'folke/persistence.nvim',
    event = "BufReadPre", -- this will only start session saving when a file is opened
    opts = {
      -- add any custom options here
    },
  },
}

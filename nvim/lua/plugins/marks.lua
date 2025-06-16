-- lua/plugins/marks.lua

return {
  {
    'chentoast/marks.nvim',
    -- This plugin is lazy-loaded by default on events like setting/using a mark,
    -- so no need to specify event or lazy=false.
    config = function()
      require('marks').setup({
        -- You can add any custom configuration here.
        -- The default settings are generally excellent.
        -- For example, to change the signs shown in the gutter:
        -- signs = {
        --   a = { text = "A" },
        --   b = { text = "B" },
        --   -- etc.
        -- }
      })
    end,
  },
}

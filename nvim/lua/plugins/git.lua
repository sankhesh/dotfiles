-- lua/plugins/git.lua

return {
  'tpope/vim-fugitive',
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end)

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk)
          map('n', '<leader>hr', gitsigns.reset_hunk)

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          map('n', '<leader>hS', gitsigns.stage_buffer)
          map('n', '<leader>hR', gitsigns.reset_buffer)
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hi', gitsigns.preview_hunk_inline)

          map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end)

          map('n', '<leader>hd', gitsigns.diffthis)

          map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
          end)

          map('n', '<leader>hQ', function()
            gitsigns.setqflist('all')
          end)
          map('n', '<leader>hq', gitsigns.setqflist)

          -- Toggles
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
          map('n', '<leader>tw', gitsigns.toggle_word_diff)

          -- Text object
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
        end,
      })
    end,
  },
  {
    'rbong/vim-flog',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'tpope/vim-fugitive', -- vim-flog requires fugitive
    },
    config = function()
      -- Example keymap to open Flog
      vim.keymap.set('n', '<leader>gl', ':Flog<CR>', { desc = 'Open Flog (git log)' })

      -- Enable folding for Flog/diff buffers: fold by file diffs and hunks.
      -- Detect buffers that look like git diffs (contain a '^diff --git' line in the
      -- first N lines) and set a simple foldexpr that gives top-level folds to
      -- 'diff --git' lines and nested folds to hunk headers ('@@ ... @@').
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufWinEnter' }, {
        callback = function(ev)
          local buf = ev.buf
          -- If buffer already unloaded or invalid, skip
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          -- Check first 200 lines for a git-diff header. This catches Flog output
          -- without relying on filetype or buffer name.
          local lines = vim.api.nvim_buf_get_lines(
            buf,
            0,
            math.min(200, vim.api.nvim_buf_line_count(buf)),
            false
          )
          local looks_like_diff = false
          for _, l in ipairs(lines) do
            if l:match('^diff %-%-git') then
              looks_like_diff = true
              break
            end
          end

          if looks_like_diff then
            -- Define a Lua-based fold function for flog/diff buffers. It scans
            -- upward from the current line to find the nearest 'diff --git' or
            -- hunk ('@@') header and returns a numeric fold level (1 for file
            -- diff, 2 for hunk). This avoids complex Vimscript expressions and
            -- works reliably when lines between headers exist.
            _G.FlogFold = function(lnum)
              local buf = vim.api.nvim_get_current_buf()
              local n = tonumber(lnum) or 1
              for i = n, 1, -1 do
                local ok, line = pcall(vim.api.nvim_buf_get_lines, buf, i - 1, i, false)
                line = ok and (line and line[1] or '') or ''
                if line:match('^diff %-%-git') then
                  return 1
                end
                if line:match('^@@') then
                  return 2
                end
              end
              return 0
            end

            -- fold options are window-local in Neovim, set them on the current
            -- window. Fallback to buffer options if window API fails.
            local ok_win_set = pcall(vim.api.nvim_win_set_option, 0, 'foldmethod', 'expr')
            if not ok_win_set then
              vim.api.nvim_buf_set_option(buf, 'foldmethod', 'expr')
            end
            ok_win_set = pcall(vim.api.nvim_win_set_option, 0, 'foldexpr', 'v:lua.FlogFold(v:lnum)')
            if not ok_win_set then
              vim.api.nvim_buf_set_option(buf, 'foldexpr', 'v:lua.FlogFold(v:lnum)')
            end

            -- Make sure folding is enabled for this window/buffer and start folded.
            pcall(vim.api.nvim_win_set_option, 0, 'foldenable', true)
            vim.api.nvim_buf_set_option(buf, 'foldenable', true)
            pcall(vim.api.nvim_win_set_option, 0, 'foldlevel', 0)
            vim.api.nvim_buf_set_option(buf, 'foldlevel', 0)
          end
        end,
      })
    end,
  }, -- {
  --   'NeogitOrg/neogit',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'sindrets/diffview.nvim', -- Keep this dependency
  --     'nvim-telescope/telescope.nvim',
  --   },
  --   config = function()
  --     require('neogit').setup({
  --       -- Configure neogit to use diffview for diffs
  --       integrations = {
  --         diffview = true,
  --       },
  --     })
  --   end,
  -- },
  -- Add the diffview plugin configuration
  {
    'sindrets/diffview.nvim',
    -- No specific config needed unless you want to customize it
    -- It will be automatically used by neogit
  },
}

-- lua/plugins/codecompanion.lua

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'folke/snacks.nvim',
  },
  event = 'VeryLazy',
  config = function()
    local default_interaction = {
      adapter = 'dgx_spark',
      model = 'Meta-Llama-3-8B-Instruct',
    }
    local config = require('plugins.config')

    require('codecompanion').setup({
      interactions = {
        chat = vim.tbl_extend('force', default_interaction, {}),
        inline = vim.tbl_extend('force', default_interaction, {}),
      },
      adapters = {
        -- HTTP (OpenAI-compatible) adapters:
        http = {
          dgx_spark = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              env = {
                -- LAN name or IP of the DGX Spark reachable from this machine
                -- (use the IP or a Tailscale name if 'spearca' doesn't resolve).
                url = config.dgx.url,
                -- Auth is disabled on the proxy; any non-empty value works.
                api_key = config.dgx.api_key,
                chat_url = config.dgx.chat_url,
                models_endpoint = config.dgx.models_endpoint,
              },
              schema = {
                model = {
                  -- Fast, reliable llama.cpp default. Other good llama.cpp picks:
                  --   Phi-4, Meta-Llama-3.1-70B-Instruct,
                  --   Qwen3.5-35B-A3B-Uncensored-HauhauCS-Aggressive
                  -- vLLM models (Qwen3-Coder-Next-FP8-Dynamic, NVIDIA-Nemotron-3-Nano-4B-FP8,
                  -- Qwen2-7B) cold-load in minutes — pre-warm before selecting them.
                  default = 'Meta-Llama-3-8B-Instruct',
                },
              },
            })
          end,
        },
        -- ACP adapters (unchanged):
        acp = {
          claude_code = function()
            local home = vim.fn.expand('~')
            local file_path = vim.fn.fnamemodify(home .. '/.claude_code_apitoken', ':p')

            local token = ''
            local f = io.open(file_path, 'r')
            if f then
              token = f:read('*a'):gsub('%s+', '')
              f:close()
            else
              vim.notify('Could not find Claude Code token at ' .. file_path, vim.log.levels.WARN)
            end

            return require('codecompanion.adapters').extend('claude_code', {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = token,
              },
            })
          end,
        },
      },
    })

    vim.keymap.set(
      { 'n', 'v' },
      '<leader>a',
      '<cmd>CodeCompanionActions<cr>',
      { noremap = true, silent = true, desc = 'Code Companion Actions' }
    )
    vim.keymap.set(
      'n',
      '<leader>c',
      '<cmd>CodeCompanionChat Toggle<cr>',
      { noremap = true, silent = true, desc = 'Code Companion Chat' }
    )
    vim.keymap.set(
      'v',
      '<leader>c',
      '<cmd>CodeCompanionChat Add<cr>',
      { noremap = true, silent = true, desc = 'Add selected text to the chat buffer' }
    )
    -- Show llama-swap model load state during codecompanion requests
    do
      local llamaswap_url = config.llamaswap_url
      local timer = nil

      local function poll_and_notify()
        vim.system(
          { 'curl', '-s', '--max-time', '2', llamaswap_url },
          { text = true },
          function(res)
            if res.code ~= 0 or not res.stdout or res.stdout == '' then
              return
            end
            local ok, data = pcall(vim.json.decode, res.stdout)
            if not ok or not data.running then
              return
            end
            local msg, loading = {}, false
            for _, r in ipairs(data.running) do
              table.insert(msg, ('%s → %s'):format(r.model, r.state))
              if r.state ~= 'ready' then
                loading = true
              end
            end
            vim.schedule(function()
              if pcall(require, 'snacks') then
                Snacks.notify(table.concat(msg, '\n'), {
                  id = 'dgx-loading',
                  title = loading and 'DGX Spark: loading model…' or 'DGX Spark',
                  level = loading and 'warn' or 'info',
                })
              else
                vim.notify(
                  table.concat(msg, '\n'),
                  loading and vim.log.levels.WARN or vim.log.levels.INFO
                )
              end
            end)
          end
        )
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequestStarted',
        callback = function()
          if timer then
            return
          end
          timer = vim.uv.new_timer()
          timer:start(0, 1500, poll_and_notify) -- poll every 1.5s
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequestFinished',
        callback = function()
          if timer then
            timer:stop()
            timer:close()
            timer = nil
          end
          vim.schedule(function()
            if pcall(require, 'snacks') and Snacks.notifier and Snacks.notifier.hide then
              Snacks.notifier.hide('dgx-loading')
            end
          end)
        end,
      })

      -- Ensure timer is stopped when Neovim exits
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          if timer then
            timer:stop()
            timer:close()
          end
        end,
      })
    end
  end,
}

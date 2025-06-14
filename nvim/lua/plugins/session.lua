-- lua/plugins/session.lua

return {
  {
    'olimorris/persisted.nvim',
    lazy = false, -- Load this plugin on startup
    config = function()
      local persisted = require('persisted')

      persisted.setup({
        -- Enable autostarting sessions
        autosave = true,
        autostart = true,
        autoload = true,
        on_autoload_no_session = function()
          vim.notify('No existing session to load.')
        end,
        use_git_branch = true,
        save_dir = vim.fn.stdpath('config') .. '/sessions/', -- Change save directory
        on_load = function()
          print('Session loaded!')
        end,
      })

      -- Add a command to select a session and change directory
      vim.api.nvim_create_user_command('SessionSelect', function()
        local session_paths = persisted.list()
        if #session_paths == 0 then
          vim.notify('No sessions available.')
          return
        end

        -- Create a list of display names (just the folder name)
        local display_names = {}
        for _, path in ipairs(session_paths) do
          table.insert(display_names, vim.fn.fnamemodify(path, ':t'))
        end

        vim.ui.select(display_names, {
          prompt = 'Select a session to load:',
        }, function(choice, index)
          -- If the user cancels, choice will be nil.
          if not choice then
            return
          end

          -- Get the full path of the selected session file
          local selected_session_file = session_paths[index]
          -- Get just the filename from the full path
          local session_filename = vim.fn.fnamemodify(selected_session_file, ':t')

          -- Truncate at the first '@' to get the encoded project path
          local encoded_path = session_filename:match('([^@]+)')

          if not encoded_path then
            vim.notify('Could not parse session path from filename: ' .. session_filename, 'error')
            return
          end

          local reconstructed_path
          -- Check if we are on Windows
          if vim.fn.has('win32') == 1 then
            -- On Windows, the path is encoded like D%Projects%...
            local parts = vim.split(encoded_path, '%%')
            -- The first part is the drive letter, so we append ":"
            parts[1] = parts[1] .. ':'
            -- Join the parts back together with the Windows separator
            reconstructed_path = table.concat(parts, '\\')
          else
            -- On Linux/macOS, just replace '%' with '/'
            reconstructed_path = encoded_path:gsub('%%', '/')
          end

          -- Change directory to the reconstructed path
          vim.cmd.cd(vim.fn.fnameescape(reconstructed_path))
          vim.notify('Changed directory to: ' .. reconstructed_path)

          -- Finally, load the session
          vim.api.nvim_command('SessionLoad')
        end)
      end, {})
    end,
  },
}

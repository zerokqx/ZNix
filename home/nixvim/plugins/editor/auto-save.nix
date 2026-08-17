{ lib, config, ... }:
{
  plugins.auto-save = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };
    settings = {
      enabled = true;
      debounce_delay = 1000;
      write_all_buffers = false;
      noautocmd = false;
      lockmarks = false;
      trigger_events = {
        immediate_save = [
          "BufLeave"
          "FocusLost"
        ];
        defer_save = [
          "InsertLeave"
          "TextChanged"
        ];
        cancel_deferred_save = [
          "InsertEnter"
        ];
      };
      condition = {
        __raw = ''
          function(buf)
            if not vim.api.nvim_buf_is_valid(buf) then
              return false
            end

            -- Don't save non-modifiable or readonly buffers
            if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
              return false
            end

            -- Only save normal buffers (ignore terminal, prompt, quickfix, nofile, etc.)
            if vim.bo[buf].buftype ~= "" then
              return false
            end

            -- Don't save unnamed scratch buffers
            if vim.api.nvim_buf_get_name(buf) == "" then
              return false
            end

            -- Filter out special/temporary filetypes
            local ft = vim.bo[buf].filetype
            local ignored_filetypes = {
              gitcommit = true,
              gitrebase = true,
              hgcommit = true,
              svn = true,
              DressingInput = true,
              TelescopePrompt = true,
              ["snacks_picker_input"] = true,
              harpoon = true,
              noice = true,
              notify = true,
            }
            if ignored_filetypes[ft] then
              return false
            end

            return true
          end
        '';
      };
    };
  };

  keymaps = lib.mkIf config.plugins.auto-save.enable [
    {
      mode = "n";
      key = "<leader>ta";
      action = "<cmd>ASToggle<CR>";
      options = {
        silent = true;
        desc = "Toggle Auto-Save";
      };
    }
  ];
}



{
  lib,
  config,
  ...
}:
{

  plugins.snacks = {
    enable = true;

    settings = {
      quickfiles.enabled = true;
      dim.enabled = false;
      toggle.enabled = true;
      bufdelete.enabled = true;
      scroll.enabled = false;
      words.enabled = false;
      styles = {
        notification = {
          backdrop = false;
          wo.winblend = 0;
        };
        notification_history = {
          backdrop = false;
          wo.winblend = 0;
        };
        input = {
          backdrop = false;
          wo.winblend = 0;
        };
        select = {
          backdrop = false;
          wo.winblend = 0;
        };
        float = {
          backdrop = false;
          wo.winblend = 0;
        };
        terminal = {
          backdrop = false;
          wo.winblend = 0;
        };
      };
      indent = {
        enabled = true;
        char = "│";
      };
      input.enabled = true;
      explorer = {
        border = "rounded";
        enabled = true;
        ignored = true;
      };
      lazygit = {
        enabled = true;
        win = {
          position = "float";
          width = 0.95;
          height = 0.9;
          border = "rounded";
          wo.winblend = 0;
        };
      };
      picker = {
        win = {
          input.wo.winblend = 0;
          list.wo.winblend = 0;
          preview.wo.winblend = 0;
        };
      };
      statuscolumn = {
        enabled = true;
        left = [
          "mark"
          "sign"
        ];
        right = [
          "fold"
        ];
        folds = {
          open = false;
          git_hl = false;
        };
        refresh = 500;
      };
      scope = {
        enabled = true;
      };
      notifier = {
        enabled = true;
      };
      terminal = {
        enabled = true;
        win = {
          position = "bottom";
          width = 100;
          height = 18;
          border = "rounded";
          wo.winblend = 0;
        };
      };
    };
  };

  keymaps = lib.mkIf config.plugins.snacks.enable (
    [
      {
        mode = "n";
        key = "<leader>shc";
        action = "<cmd>lua Snacks.picker.command_history()<CR>";
        options = {
          silent = true;
          desc = "История комманд";
        };
      }

      {
        mode = "n";
        key = "<leader>sk";
        action = "<cmd>lua Snacks.picker.keymaps()<CR>";
        options = {
          silent = true;
          desc = "Hotkeys";
        };
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>lua Snacks.picker.grep({ layout = { preset = 'dropdown', preview = false, layout = { width = 0.62, height = 0.50 } } })<CR>";
        options = {
          silent = true;
          desc = "Поиск по файлам с grep";
        };
      }
      {
        mode = "n";
        key = "<leader>,";
        action = "<cmd>lua Snacks.picker.buffers()<CR>";
        options = {
          silent = true;
          desc = "Поиск по буфферам";
        };
      }
      {
        mode = "n";
        key = "<leader><space>";
        action = "<cmd>lua Snacks.picker.files({ layout = { preset = 'dropdown', preview = false, layout = { width = 0.62, height = 0.50 } } })<CR>";
        options = {
          silent = true;
          desc = "Поиск по файлам (alt)";
        };
      }
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>lua Snacks.picker.files({ layout = { preset = 'dropdown', preview = false, layout = { width = 0.62, height = 0.50 } } })<CR>";
        options = {
          silent = true;
          desc = "Файлы";
        };
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>lua Snacks.picker.grep({ layout = { preset = 'dropdown', preview = false, layout = { width = 0.62, height = 0.50 } } })<CR>";
        options = {
          silent = true;
          desc = "Grep";
        };
      }
      {
        mode = "n";
        key = "<leader>sb";
        action = "<cmd>lua Snacks.picker.buffers()<CR>";
        options = {
          silent = true;
          desc = "Буфферы";
        };
      }

      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>lua Snacks.picker.git_grep()<CR>";
        options = {
          silent = true;
          desc = "Git Grep";
        };
      }

      {
        mode = "n";
        key = "<leader>gll";
        action = "<cmd>lua Snacks.picker.git_log_line()<CR>";
        options = {
          silent = true;
          desc = "Git Log (Line)";
        };
      }

      {
        mode = "n";
        key = "<leader>glf";
        action = "<cmd>lua Snacks.picker.git_log_file()<CR>";
        options = {
          silent = true;
          desc = "Git Log (File)";
        };
      }

      {
        mode = "n";
        key = "<leader>gl";
        action = "<cmd>lua Snacks.picker.git_log()<CR>";
        options = {
          silent = true;
          desc = "Git Log";
        };
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>lua Snacks.picker.git_stash()<CR>";
        options = {
          silent = true;
          desc = "Git Stash";
        };
      }

      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>lua Snacks.picker.git_diff()<CR>";
        options = {
          silent = true;
          desc = "Git Diff";
        };
      }

      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>lua Snacks.picker.git_branches()<CR>";
        options = {
          silent = true;
          desc = "Git Branches";
        };
      }

      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
        options = {
          silent = true;
          desc = "Diagnostics (buffer)";
        };
      }

      {
        mode = "n";
        key = "<leader>uC";
        action = "<cmd>lua Snacks.picker.colorschemes()<CR>";
        options = {
          silent = true;
          desc = "Colorschemes";
        };
      }

      {
        mode = "n";
        key = "<leader>sD";
        action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
        options = {
          silent = true;
          desc = "Diagnostics";
        };
      }

      {
        mode = "n";
        key = "<leader>sy";
        action = "<cmd>lua Snacks.picker.cliphist()<CR>";
        options = {
          silent = true;
          desc = "Yank history";
        };
      }

      {
        mode = "n";
        key = "<leader>sp";
        action = "<cmd>lua Snacks.picker.projects()<CR>";
        options = {
          silent = true;
          desc = "Projects";
        };
      }
    ]
    ++ lib.optional (config.plugins.snacks.settings.explorer.enabled) {
      mode = "n";
      key = "<leader>e";
      action = ":lua Snacks.explorer()<CR>";
      options = {
        silent = true;
        desc = "Explorer";
      };
    }
    ++ lib.optional (config.plugins.snacks.settings.terminal.enabled) {
      mode = [
        "n"
        "t"
      ];
      key = "<C-/>";
      action = "<cmd>lua Snacks.terminal.toggle()<CR>";
      options = {
        silent = true;
        desc = "Terminal";
      };
    }
    ++ lib.optional (config.plugins.snacks.settings.lazygit.enabled) {
      action = ":lua Snacks.lazygit()<CR>";
      key = "<leader>gz";
      mode = "n";
      options = {
        desc = "Lazygit";
        silent = true;
      };
    }
    ++ lib.optionals (config.plugins.snacks.settings.bufdelete.enabled) [

      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>lua Snacks.bufdelete.delete()<cr>";
        options.desc = "Close buffer";
      }
      {
        mode = "n";
        key = "<leader>bo";
        action = ''<cmd>lua Snacks.bufdelete.other()<cr>'';
        options.desc = "Close all buffers but current";
      }
      {
        mode = "n";
        key = "<leader>bO";
        action = ''<cmd>lua Snacks.bufdelete.all()<cr>'';
        options.desc = "Close all buffers";
      }
    ]
  );
}

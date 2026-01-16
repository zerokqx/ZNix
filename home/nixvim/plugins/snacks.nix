{
  lib,
  config,
  ...
}:

{

  plugins.snacks = {
    enable = true;

    settings = {
      quckfiles.enabled = true;
      dim.enabled = true;
      toggle.enabled = true;
      bufdelete.enabled = true;
      scroll.enabled = false;
      explorer = {
        enabled = true;
      };
      statuscolumn = {
        enabled = true;
        left = [
          "mark"
          "sign"
        ];
        right = [
          "fold"
          "git"
        ];
        folds = {
          open = false;
          git_hl = false;
        };
        refresh = 200;
        git = {
          patterns = [
            "GitSign"
            "MiniDiffSign"
          ];
        };
      };
      scope = {
        enbled = true;
      };
      notifier = {
        enabled = true;

        # icons = {
        #   error = icons.error;
        #   warn = icons.warn;
        #   info = icons.info;
        #   debug = icons.debug;
        # };
      };
      terminal = {
        enabled = true;
        win = {
          position = "float";
          width = 100;
          height = 20;
          border = "rounded";
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
    # добавляем хоткей на терминал ТОЛЬКО если terminal.enable == false
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

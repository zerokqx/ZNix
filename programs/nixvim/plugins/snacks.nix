{ lib, config, ... }:
{
  plugins.snacks = {
    enable = true;

    settings = {
      indent.enabled = true;
      quckfiles.enabled = true;
      toggle.enabled = true;
      words.enabled = true;

      explorer = {
        enabled = false; # <--- если хочешь хоткей <leader>e — сделай true
      };

      animate = { };

      terminal.win = {
        position = "float";
        width = 100;
        height = 20;
        border = "rounded";
      };
    };
  };

  keymaps = lib.mkIf config.plugins.snacks.enable (
    [
      # ===== Snacks Picker =====

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
    ++ lib.optional config.plugins.snacks.settings.explorer.enabled {
      mode = "n";
      key = "<leader>e";
      action = ":lua Snacks.explorer()<CR>";
      options = {
        silent = true;
        desc = "Snacksplorer";
      };
    }
  );
}

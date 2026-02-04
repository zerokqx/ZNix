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
      scroll.enabled = true;
      words.enabled = true;
      indent = {
        enabled = true;
        char = "│";
      };
      input.enabled = true;
      explorer = {
        border = "none";
        enabled = true;
      };
      lazygit = {
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
        refresh = 500;
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

      };
      terminal = {
        enabled = true;
        win = {
          position = "bottom";
          width = 100;
          height = 20;
          border = "rounded";
        };
      };
    };
  };

  extraConfigLua = ''
    -- Animated slide-in for Snacks Explorer (only when it opens as a floating window)
    local function snacks_explorer_animate(win, cfg)
      local function to_number(val)
        if type(val) == "table" then
          return val[false] or val[1] or 0
        end
        return val or 0
      end

      local width = cfg.width or 40
      local target_col = to_number(cfg.col)
      local start_col = -math.max(width, math.abs(target_col) + width)

      local steps = 12
      local interval = 10
      local delta = (target_col - start_col) / steps

      local function set_col(winid, col)
        local new_cfg = vim.deepcopy(cfg)
        new_cfg.col = col
        pcall(vim.api.nvim_win_set_config, winid, new_cfg)
      end

      set_col(win, start_col)
      local timer = vim.loop.new_timer()
      local i = 0
      timer:start(0, interval, function()
        i = i + 1
        if not vim.api.nvim_win_is_valid(win) then
          timer:stop()
          timer:close()
          return
        end
        local col = start_col + delta * i
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            set_col(win, col)
          end
        end)
        if i >= steps then
          timer:stop()
          timer:close()
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) then
              set_col(win, target_col)
            end
          end)
        end
      end)
    end

    function _G.SnacksExplorerAnimated()
      local ok, snacks = pcall(require, "snacks")
      if not ok or not snacks.explorer then
        vim.notify("Snacks explorer not available", vim.log.levels.WARN)
        return
      end

      -- Toggle off if already open
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local ft = vim.api.nvim_get_option_value("filetype", { win = win })
        if ft == "snacks_explorer" then
          pcall(vim.api.nvim_win_close, win, true)
          return
        end
      end

      snacks.explorer()

      vim.schedule(function()
        local target
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local ft = vim.api.nvim_get_option_value("filetype", { win = win })
          if ft == "snacks_explorer" then
            target = win
            break
          end
        end
        if not target then
          return
        end
        local cfg = vim.api.nvim_win_get_config(target)
        if cfg.relative == "" or not cfg.col then
          return
        end
        snacks_explorer_animate(target, cfg)
      end)
    end
  '';

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
    ++ lib.optional (config.plugins.snacks.settings.explorer.enabled) {
      mode = "n";
      key = "<leader>e";
      action = ":lua SnacksExplorerAnimated()<CR>";
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

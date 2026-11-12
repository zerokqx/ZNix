{ lib, ... }:
{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;

    modules = {

      basics = {
        options = {
          basic = true;
          extra_ui = true;
          win_borders = "rounded";
        };
        mappings = {
          basic = true;
          option_toggle_prefix = "\\";
          windows = true;
          move_with_alt = false;
        };
        autocommands = {
          basic = true;
          relnum_in_visual_mode = true;
        };
      };

      statusline = {
        use_icons = true;
      };

      tabline = {
        show_icons = true;
      };

      map = { };

      hipatterns = {
        highlighters = {
          hex_color.__raw = "require('mini.hipatterns').gen_highlighter.hex_color()";
          fixme = {
            pattern = "%f[%w]()FIXME()%f[%W]";
            group = "MiniHipatternsFixme";
          };
          hack = {
            pattern = "%f[%w]()HACK()%f[%W]";
            group = "MiniHipatternsHack";
          };
          todo = {
            pattern = "%f[%w]()TODO()%f[%W]";
            group = "MiniHipatternsTodo";
          };
          note = {
            pattern = "%f[%w]()NOTE()%f[%W]";
            group = "MiniHipatternsNote";
          };
        };
      };

      ai = {
        n_lines = 500;
        search_method = "cover_or_next";
      };

      move = {
        mappings = {
          left = "<M-h>";
          right = "<M-l>";
          down = "<M-j>";
          up = "<M-k>";
          line_left = "<M-h>";
          line_right = "<M-l>";
          line_down = "<M-j>";
          line_up = "<M-k>";
        };
      };

      splitjoin = {
        mappings = {
          toggle = "gS";
        };
      };

      align = {
        mappings = {
          start = "ga";
          start_with_preview = "gA";
        };
      };

      bracketed = {
        buffer = {
          suffix = "b";
          options = { };
        };
        comment = {
          suffix = "c";
          options = { };
        };
        conflict = {
          suffix = "x";
          options = { };
        };
        diagnostic = {
          suffix = "d";
          options = { };
        };
        file = {
          suffix = "f";
          options = { };
        };
        quickfix = {
          suffix = "q";
          options = { };
        };
        treesitter = {
          suffix = "t";
          options = { };
        };
        undo = {
          suffix = "u";
          options = { };
        };
      };

      pairs = { };

      surround = { };

      icons = { };
    };
  };

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", { callback = function() MiniMap.open() end })
    vim.keymap.set("n", "<leader>um", MiniMap.toggle, { desc = "Показать или скрыть миникарту" })

    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#1a1b26", bg = "#f7768e", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack",  { fg = "#1a1b26", bg = "#e0af68", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo",  { fg = "#1a1b26", bg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote",  { fg = "#1a1b26", bg = "#9ece6a", bold = true })

    -- mini.tabline's format callback only accepts plain text. Add icon colors
    -- after rendering, scanning the visible tabs once and keeping their highlights.
    local make_tabline = MiniTabline.make_tabline_string
    MiniTabline.make_tabline_string = function()
      local tabline = make_tabline()
      local tab = "()%%#(MiniTabline%a+)#(%%(%d+)@MiniTablineSwitchBuffer@) ([^%s%%]+) "
      return (tabline:gsub(tab, function(pos, tab_hl, button, buf, shown_icon)
        -- A filename can contain literal percent signs, escaped by mini.tabline.
        if pos > 1 and tabline:sub(pos - 1, pos - 1) == "%" then return end
        local icon, icon_hl = MiniIcons.get("file", vim.api.nvim_buf_get_name(tonumber(buf)))
        if icon ~= shown_icon or not icon_hl then return end
        return string.format("%%#%s#%s %%#%s#%s%%#%s# ", tab_hl, button, icon_hl, icon, tab_hl)
      end))
    end
  '';
}

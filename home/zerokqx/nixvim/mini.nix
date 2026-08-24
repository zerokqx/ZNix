{ lib, ... }:
{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;

    modules = {

      comment = {
        options = {
          custom_commentstring.__raw = ''
            function()
              return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
            end
          '';
        };
      };

      basics = {
        options = {
          basic = true;
          extra_ui = true;
          win_borders = "single";
        };
        mappings = {
          basic = true;
          option_toggle_prefix = "\\";
          windows = true;
          move_with_alt = true;
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
          left = "<M-Left>";
          right = "<M-Right>";
          down = "<M-Down>";
          up = "<M-Up>";
          line_left = "<M-Left>";
          line_right = "<M-Right>";
          line_down = "<M-Down>";
          line_up = "<M-Up>";
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

      snippets = {
        snippets.__raw = "{ require('mini.snippets').gen_loader.from_lang() }";
        mappings = {
          expand = "<C-j>";
          jump_next = "<C-l>";
          jump_prev = "<C-h>";
          stop = "<C-c>";
        };
      };
    };
  };

  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#1a1b26", bg = "#f7768e", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack",  { fg = "#1a1b26", bg = "#e0af68", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo",  { fg = "#1a1b26", bg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote",  { fg = "#1a1b26", bg = "#9ece6a", bold = true })
  '';
}

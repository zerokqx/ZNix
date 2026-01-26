{ config, lib, ... }:

{
  plugins = {
    treesitter = {
      enable = true;
      folding.enable = true;
      settings = {
        highlight = {
          additional_vim_regex_highlighting = true;
          enable = true;
          disable = # Lua
            ''
              function(lang, bufnr)
                return vim.api.nvim_buf_line_count(bufnr) > 10000
              end
            '';
        };

        incremental_selection.enable = false;
        indent.enable = true;
      };
      nixvimInjections = true;
    };

    treesitter-context = {

      enable = false;
      settings = {
        max_lines = 4;
        min_window_height = 40;
        multiwindow = true;
        separator = "▬";
      };
    };

    treesitter-refactor = {
      inherit (config.plugins.treesitter) enable;

      settings = {
        highlight_definitions = {
          enable = true;
          clear_on_cursor_move = true;
        };
        smart_rename.enable = true;
        navigation.enable = true;
      };
    };
  };

  keymaps = lib.mkIf config.plugins.treesitter-context.enable [
    {
      mode = "n";
      key = "<leader>uT";
      action = "<cmd>TSContextToggle<cr>";
      options.desc = "Treesitter Context toggle";
    }
  ];
}

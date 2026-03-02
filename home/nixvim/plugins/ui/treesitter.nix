{ config, lib, ... }:

{
  plugins = {
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          additional_vim_regex_highlighting = false;
          enable = true;
        };
        incremental_selection.enable = true;
        indent.enable = true;
      };
      nixvimInjections = true;
    };

    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 4;
        min_window_height = 40;
        multiwindow = true;
        separator = "─";
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

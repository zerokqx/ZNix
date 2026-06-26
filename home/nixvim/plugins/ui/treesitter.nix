{ config, lib, ... }:

{
  plugins = {
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          additional_vim_regex_highlighting = false;
        };
        incremental_selection.enable = true;
        indent.enable = true;
        sync_install = false;
      };
      highlight = {
        enable = true;
      };
      nixvimInjections = true;
    };

    treesitter-context = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };
      settings = {
        max_lines = 3;
        min_window_height = 32;
        multiwindow = false;
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

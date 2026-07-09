{ lib, ... }:
{

  plugins.mini-diff = {
    enable = true;
    lazyLoad.enable = false;
    settings = {

      delay = {
        text_change = 200;
      };
      mappings = {
        apply = "gh";
        goto_first = "[H";
        goto_last = "]H";
        goto_next = "]h";
        goto_prev = "[h";
        reset = "gH";
        textobject = "gh";
      };
      options = {
        algorithm = "histogram";
        indent_heuristic = true;
        linematch = 60;
        wrap_goto = false;
      };
      source = lib.nixvim.mkRaw "nil";
      view = {
        priority = 199;
        signs = {
          add = "▎";
          change = "▎";
          delete = "▎";
        };
        style = "sign";
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>go";
      action = "<cmd>lua require('mini.diff').toggle_overlay()<cr>";
      options = {
        silent = true;
        desc = "Toggle Git Diff overlay";
      };
    }
  ];
}

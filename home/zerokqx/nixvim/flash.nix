{ ... }:
{
  plugins.flash = {
    enable = true;
    settings = {
      labels = "asdfghjklqwertyuiopzxcvbnm";
      search = {
        mode = "exact";
        incremental = false;
      };
      jump = {
        autojump = false;
      };
    };
  };

  keymaps = [
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<cmd>lua require('flash').jump()<cr>";
      options = {
        silent = true;
        desc = "Flash Jump";
      };
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action = "<cmd>lua require('flash').treesitter()<cr>";
      options = {
        silent = true;
        desc = "Flash Treesitter";
      };
    }
    {
      mode = "o";
      key = "r";
      action = "<cmd>lua require('flash').remote()<cr>";
      options = {
        silent = true;
        desc = "Remote Flash";
      };
    }
    {
      mode = [
        "o"
        "x"
      ];
      key = "R";
      action = "<cmd>lua require('flash').treesitter_search()<cr>";
      options = {
        silent = true;
        desc = "Treesitter Search";
      };
    }
    {
      mode = [ "c" ];
      key = "<c-s>";
      action = "<cmd>lua require('flash').toggle()<cr>";
      options = {
        silent = true;
        desc = "Toggle Flash Search";
      };
    }
  ];
}

{
  plugins.leap.enable = true;
  plugins.repeat.enable = true;
  keymaps = [

    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<Plug>(leap)";
      options = {
        silent = true;
      };
    }
    {
      mode = "n";

      key = "S";
      action = "<Plug>(leap-from-window)";
      options = {
        silent = true;
      };
    }
  ];
}

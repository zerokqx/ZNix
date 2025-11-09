{ lib, config, ... }:
{

  plugins.snacks = {
    enable = true;
    settings = {
      indent = {
        enabled = true;
      };
      quckfiles = {
        enabled = true;
      };
      toggle = {
        enabled = true;
      };
      words = {
        enabled = true;
      };
      explorer = {
        enabled = false;
      };
      animate = { };
      terminal = {
        win = {

          position = "float";
          width = 100;
          height = 20;
          border = "rounded";
        };
      };

    };
  };
  keymaps = lib.mkIf config.plugins.snacks.settings.explorer.enabled [
    {

      mode = "n";
      key = "<leader>e";
      action = ":lua Snacks.explorer()<CR>";
      options = {
        silent = true;
        desc = "Переключиться на окно слева";
      };
    }
  ];
}

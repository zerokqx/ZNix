{ lib, config, ... }:
{
  plugins.auto-session = {
    enable = true;
  };
  keymaps = lib.mkIf config.plugins.auto-session.enable [

    {

      mode = "n";
      key = "<leader>ssd";
      action = "<cmd>AutoSession deletePicker<CR>";
      options = {
        silent = true;
        desc = "Удалить сессии";
      };
    }
    {

      mode = "n";
      key = "<leader>S";
      action = "<cmd>AutoSession search<CR>";
      options = {
        silent = true;
        desc = "Поиск сессий";
      };
    }
  ];
}

{ lib, config, ... }:
{
  plugins.mini-bufremove = {
    enable = false;
    settings = {
      silent = true;
    };
  };
  keymaps = lib.mkIf config.plugins.mini-bufremove.enable [

    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>lua MiniBufremove.delete()<cr>";
      options = {
        silent = true;
        desc = "Закрыть буффер";
      }

      ;
    }

  ];
}

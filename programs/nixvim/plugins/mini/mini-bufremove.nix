{ ... }:
{
  plugins.mini-bufremove = {
    enable = true;
    settings = {
      silent = true;
    };
  };
  keymaps = [

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

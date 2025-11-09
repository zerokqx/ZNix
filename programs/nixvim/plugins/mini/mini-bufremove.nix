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

    {
      mode = "n";
      key = "<leader>bo";
      action = "<cmd>lua MiniBufremove.delete(0, true)<cr>";
      options = {
        silent = true;
        desc = "Удалить все буферы кроме текущего";
      };
    }
  ];
}

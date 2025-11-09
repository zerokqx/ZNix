{
  plugins.mini-pick = {
    enable = true;

    settings = {

      window = {
        prompt_prefix = "➤ ";
        config = {
          border = "rounded";
          width = 50;
          height = 20;
        };
      };
    };
  };

  keymaps = [

    {
      mode = "n";
      key = "<leader>sf";
      action = "<cmd>Pick files<cr>";
      options = {
        silent = true;
        desc = "Поиск по файлам";
      };
    }

    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Pick grep_live<cr>";
      options = {
        silent = true;
        desc = "Поиск по файлам с grep";
      };
    }

    {
      mode = "n";
      key = "<leader>,";
      action = "<cmd>Pick buffers<cr>";
      options = {
        silent = true;
        desc = "Поиск по буфферам";
      };
    }

    {
      mode = "n";
      key = "<leader><space>";
      action = "<cmd>Pick files<cr>";
      options = {
        silent = true;
        desc = "Поиск по файлам (alt)";
      };
    }

    {
      mode = "n";
      key = "<leader>sf";
      action = "<cmd>Pick files<cr>";
      options = {
        silent = true;
        desc = "Файлы";
      };
    }

    {
      mode = "n";
      key = "<leader>sg";
      action = "<cmd>Pick grep_live<cr>";
      options = {
        silent = true;
        desc = "Grep (живой поиск)";
      };
    }

    {
      mode = "n";
      key = "<leader>sb";
      action = "<cmd>Pick buffers<cr>";
      options = {
        silent = true;
        desc = "Буфферы";
      };
    }
  ];

}

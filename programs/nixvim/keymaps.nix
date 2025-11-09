{ lib, ... }:
{
  keymaps = [
    {
      key = ";";
      action = ":";
    }

    {

      mode = [
        "n"
        "i"
      ];
      key = "<C-s>";
      action = ":w<cr>";
      options = {

        silent = true;
        desc = "Save";

      };
    }
    {

      mode = "n";
      key = "<leader>cn";
      action = "<cmd>Neogen<cr>";
      options = {
        silent = true;
        desc = "Neogen";
      };
    }

    {
      mode = [
        "n"
        "t"
      ];
      key = "<C-/>";
      action = "<cmd>lua Snacks.terminal.toggle()<cr>";
      options = {
        silent = true;
        desc = "Terminal";
      };
    }

    {
      mode = "n";
      key = "<leader>qq";
      action = ":qa!<CR>";
      options = {
        silent = true;
        desc = "Выйти из ZNvim";
      };
    }

    {
      mode = "n";
      key = "ca";
      action = lib.nixvim.mkRaw "require('actions-preview').code_actions";
      options = {
        silent = true;
        desc = "Code Actions";
      };
    }

    # ✅ ОРИГИНАЛЬНЫЕ SEARCH ХОТКЕИ

    # Остальные хоткеи

    {
      mode = "n";
      key = "<leader>wd";
      action = ":close<CR>";
      options = {
        silent = true;
        desc = "Закрыть текущее окно";
      };
    }
    {
      mode = "n";
      key = "<leader>wo";
      action = ":only<CR>";
      options = {
        silent = true;
        desc = "Закрыть все окна кроме текущего";
      };
    }
    {
      mode = "n";
      key = "<leader>wq";
      action = ":quit<CR>";
      options = {
        silent = true;
        desc = "Выйти из окна";
      };
    }
    {
      mode = "n";
      key = "<leader>wh";
      action = "<C-w>h";
      options = {
        silent = true;
        desc = "Переключиться на окно слева";
      };
    }
    {
      mode = "n";
      key = "<leader>wj";
      action = "<C-w>j";
      options = {
        silent = true;
        desc = "Переключиться на окно снизу";
      };
    }
    {
      mode = "n";
      key = "<leader>wk";
      action = "<C-w>k";
      options = {
        silent = true;
        desc = "Переключиться на окно сверху";
      };
    }
    {
      mode = "n";
      key = "<leader>wl";
      action = "<C-w>l";
      options = {
        silent = true;
        desc = "Переключиться на окно справа";
      };
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = ":vsplit<CR>";
      options = {
        silent = true;
        desc = "Вертикальное разделение окна";
      };
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = ":split<CR>";
      options = {
        silent = true;
        desc = "Горизонтальное разделение окна";
      };
    }
    {
      mode = "n";
      key = "<leader>wr";
      action = "<C-w>r";
      options = {
        silent = true;
        desc = "Поменять окна местами";
      };
    }
    {
      mode = "n";
      key = "<leader>w=";
      action = "<C-w>=";
      options = {
        silent = true;
        desc = "Равномерно распределить окна";
      };
    }
  ];
}

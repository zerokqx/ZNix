{ lib, ... }:
{
  plugins.alpha = {
    enable = true;
    settings.layout = [
      {
        type = "padding";
        val = 2;
      }
      {
        type = "text";
        val = [
          "▄▄▄▄▄▄      ▄       ▄   ▄█ █▀▄▀█"
          "▀   ▄▄▀       █       █  ██ █ █ █"
          " ▄▀▀   ▄▀ ██   █ █     █ ██ █ ▄ █"
          " ▀▀▀▀▀▀   █ █  █  █    █ ▐█ █   █"
          "          █  █ █   █  █   ▐    █"
          "          █   ██    █▐        ▀"
          "                    ▐"
        ];
        opts = {
          position = "center";
          hl = "Type";
        };
      }
      {
        type = "padding";
        val = 6;
      }
      {
        type = "group";
        val = [
          {
            type = "button";
            val = "      New File    ";
            on_press.__raw = "function() vim.cmd[[ene]] end";
            opts = {
              shortcut = "n";
              keymap = [
                "n"
                "n"
                "<cmd>ene<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "button";
            val = "      Find File    ";
            on_press.__raw = "function() require('mini.pick').start({ source = { items = function() vim.cmd[[Pick files]] end } }) end";
            opts = {
              shortcut = "f";
              keymap = [
                "n"
                "f"
                "<cmd>Pick files<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "button";
            val = "      Recent Files    ";
            on_press.__raw = "function() vim.cmd[[Pick buffers]] end";
            opts = {
              shortcut = "r";
              keymap = [
                "n"
                "r"
                "<cmd>Pick buffers<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "button";
            val = "      Find Text    ";
            on_press.__raw = "function() vim.cmd[[Pick grep_live]] end";
            opts = {
              shortcut = "g";
              keymap = [
                "n"
                "g"
                "<cmd>Pick grep_live<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "padding";
            val = 2;
          }
          # НОВАЯ КНОПКА Projects
          {
            type = "button";
            val = "      Projects    ";
            on_press.__raw = ''
              function()
                Snacks.picker.projects()
              end
            '';
            opts = {
              shortcut = "p";
              keymap = [
                "n"
                "p"
                "<cmd>lua Snacks.picker.projects()<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "padding";
            val = 2;
          }
          {
            type = "button";
            val = "      Quit Neovim    ";
            on_press.__raw = "function() vim.cmd[[qa]] end";
            opts = {
              shortcut = "q";
              keymap = [
                "n"
                "q"
                "<cmd>qa<CR>"
                {
                  noremap = true;
                  silent = true;
                  nowait = true;
                }
              ];
              position = "center";
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
        ];
      }
    ];
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>ua";
      action = ":Alpha<CR>";
      options = {
        silent = true;
        desc = "Открыть Alpha";
      };
    }
  ];
}

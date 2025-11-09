{ lib, ... }:
{
  plugins.which-key = {
    enable = true;
    settings = {
      delay = 2000;
      expand = 1;
      notify = false;
      preset = false;
      replace = {
        desc = [
          [
            "<space>"
            "SPACE"
          ]
          [
            "<leader>"
            "SPACE"
          ]
          [
            "<[cC][rR]>"
            "RETURN"
          ]
          [
            "<[tT][aA][bB]>"
            "TAB"
          ]
          [
            "<[bB][sS]>"
            "BACKSPACE"
          ]
        ];
      };
      spec = [
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffers";
          icon = "󰓩 ";
        }

        {
          __unkeyed = "<leader>s";
          group = "Поиск";
          icon = "󱎸 ";
          mode = "n";
        }
        {
          __unkeyed-1 = [
            {
              __unkeyed-1 = "<leader>f";
              group = "Normal Visual Group";
            }
            {
              __unkeyed-1 = "<leader>f<tab>";
              group = "Normal Visual Group in Group";
            }
          ];
          mode = [
            "n"
            "v"
          ];
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          proxy = "<C-w>";
        }
        {
          __unkeyed-1 = "<leader>cS";
          __unkeyed-2 = "<cmd>CodeSnapSave<CR>";
          desc = "Save";
          mode = "v";
        }
        {
          __unkeyed-1 = "<leader>db";
          __unkeyed-2 = {
            __raw = ''
              function()
                require("dap").toggle_breakpoint()
              end
            '';
          };
          desc = "Breakpoint toggle";
          mode = "n";
          silent = true;
        }
      ];
      win = {
        col = 0.5;
        width = 50;
        no_overlap = true;
        title = false;
        border = "rounded";
        wo = {
          winblend = 0; # прозрачность
        };
      };
    };
  };
}

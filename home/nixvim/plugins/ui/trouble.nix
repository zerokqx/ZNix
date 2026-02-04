{ config, lib, ... }:

{
  plugins = {
    trouble = {
      lazyLoad = {
        enable = true;
        settings.cmd = "Trouble";
      };
      enable = true;

      settings = {
        auto_close = true;
        focus = true;
        icons = {
          folder_closed = " ";
          folder_open = " ";
          indent = {
            fold_closed = " ";
            fold_open = " ";
            last = "└╴";
            middle = "├╴";
            top = "│ ";
            ws = "  ";
          };
        };
        modes = {
          preview_split = {
            mode = "diagnostics";
            preview = {
              type = "split";
              relative = "win";
              position = "right";
              size = 0.5;
            };
          };
        };
      };
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>x";
        mode = "n";
        icon = "";
        group = "Trouble";
      }
    ];
  };

  keymaps = lib.mkIf config.plugins.trouble.enable [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble preview_split toggle<cr>";
      options = {
        desc = "Diagnostics toggle";
      };
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble preview_split toggle filter.buf=0<cr>";
      options = {
        desc = "Buffer Diagnostics toggle";
      };
    }
    {
      mode = "n";
      key = "<leader>us";
      action = "<cmd>Trouble symbols toggle<cr>";
      options = {
        desc = "Symbols toggle";
      };
    }
    {
      mode = "n";
      key = "<leader>xd";
      action = "<cmd>Trouble lsp_definitions toggle<cr>";
      options.desc = "Trouble: Definitions";
    }
    {
      mode = "n";
      key = "<leader>xr";
      action = "<cmd>Trouble lsp_references toggle<cr>";
      options.desc = "Trouble: References";
    }
    {
      mode = "n";
      key = "<leader>xt"; # t → type definition
      action = "<cmd>Trouble lsp_type_definitions toggle<cr>";
      options.desc = "Trouble: Type Definitions";
    }
    {
      mode = "n";
      key = "<leader>xi"; # i → implementations
      action = "<cmd>Trouble lsp_implementations toggle<cr>";
      options.desc = "Trouble: Implementations";
    }
    {
      mode = "n";
      key = "<leader>xD"; # Shift+D → declarations
      action = "<cmd>Trouble lsp_declarations toggle<cr>";
      options.desc = "Trouble: Declarations";
    }
    {
      mode = "n";
      key = "<leader>xl";
      action = "<cmd>Trouble lsp toggle focus=true win.position=right<cr>";
      options = {
        desc = "LSP Definitions / references / ... toggle";
      };
    }
    # {
    #   mode = "n";
    #   key = "<leader>xL";
    #   action = "<cmd>Trouble loclist toggle<cr>";
    #   options = {
    #     desc = "Location List toggle";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "<leader>xQ";
    #   action = "<cmd>Trouble qflist toggle<cr>";
    #   options = {
    #     desc = "Quickfix List toggle";
    #   };
    # }
  ];
}

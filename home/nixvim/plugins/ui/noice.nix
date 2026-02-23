{ lib, config, ... }:
{
  plugins.noice = {
    enable = true;
    settings = {
      default_mappings = false;

      presets = {
        command_palette = true;
        long_message_to_split = true;
        bottom_search = true;

        lsp_doc_border = true;
      };

      views = {
        hover = {
          border = "rounded";
          winoptions = {
            winblend = 10; # было 100 (невидимо). 0-20 обычно ок
          };
        };

        popup = {
          border = {
            style = "rounded";
            padding = [
              0
              1
            ];
          };
        };

        split = {
          win_options = {
            wrap = true;
          };
        };
      };

      lsp = {
        signature = {
          enabled = false;
        };

        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
      };

      messages = {
        enabled = true;
        view = "mini";
        view_error = "popup";
        view_warn = "popup";
        view_search = "virtualtext";
      };

      routes = [
        {
          filter = {
            event = "msg_show";
            kind = "";
            find = "written";
          };
          opts = {
            skip = true;
          };
        }
        {
          filter = {
            event = "msg_show";
            find = "yanked";
          };
          opts = {
            skip = true;
          };
        }
        {
          filter = {
            event = "msg_show";
            find = "search hit";
          };
          opts = {
            skip = true;
          };
        }
      ];

      commands = {
        errors = {
          filter = {
            error = true;
          };
          filter_opts = {
            reverse = true;
          };
          opts = {
            enter = true;
            format = "details";
          };
          view = "popup";
        };

        history = {
          filter = {
            any = [
              { event = "notify"; }
              { error = true; }
              { warning = true; }
              {
                event = "lsp";
                kind = "message";
              }
              { event = "msg_show"; }
            ];
          };
          opts = {
            enter = true;
            format = "details";
          };
          view = "split";
        };

        last = {
          filter = {
            any = [
              { event = "notify"; }
              { error = true; }
              { warning = true; }
              {
                event = "lsp";
                kind = "message";
              }
              { event = "msg_show"; }
            ];
          };
          filter_opts = {
            count = 1;
          };
          opts = {
            enter = true;
            format = "details";
          };
          view = "popup";
        };
      };
    };
  };

  keymaps = lib.mkIf config.plugins.noice.enable [
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>NoiceSnacks<cr>";
      options = {
        silent = true;
        desc = "Уведомления";
      };
    }

    {
      mode = "n";
      key = "<leader>nh";
      action = "<cmd>Noice history<cr>";
      options = {
        silent = true;
        desc = "Noice history";
      };
    }

    {
      mode = "n";
      key = "<leader>nl";
      action = "<cmd>Noice last<cr>";
      options = {
        silent = true;
        desc = "Noice last";
      };
    }
  ];
}

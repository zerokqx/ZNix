{ lib, config, ... }:
{
  plugins = {
    noice = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
      settings = {
        throttle = 1000 / 45;
        views = {
          popup = {
            win_options = {
              winblend = 0;
            };
          };
          cmdline_popup = {
            win_options = {
              winblend = 0;
            };
          };
          popupmenu = {
            win_options = {
              winblend = 0;
            };
          };

          hover = {
            winoptions = {
              winblend = 0;
            };
            win_options = {
              winblend = 0;
            };
            border = "rounded";
          };
        };
        lsp = {
          signature = {
            enabled = false;
          };
          progress = {
            enabled = false;
          };
        };
        default_mappings = false;
        presets = {
          command_palette = true;
          long_message_to_split = true;
          bottom_search = true;
          lsp_doc_border = true;
        };
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
                {
                  event = "notify";
                }
                {
                  error = true;
                }
                {
                  warning = true;
                }
                {
                  event = "msg_show";
                  kind = [
                    ""
                  ];
                }
                {
                  event = "lsp";
                  kind = "message";
                }
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
                {
                  event = "notify";
                }
                {
                  error = true;
                }
                {
                  warning = true;
                }
                {
                  event = "msg_show";
                  kind = [
                    ""
                  ];
                }
                {
                  event = "lsp";
                  kind = "message";
                }
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
  ];

}

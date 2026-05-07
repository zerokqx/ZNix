{ config, lib, ... }:
{
  plugins = {
    bufferline = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings = {
          event = [
            "BufReadPost"
            "BufNewFile"
          ];
          cmd = [
            "BufferLineCycleNext"
            "BufferLineCyclePrev"
            "BufferLineCloseLeft"
            "BufferLineCloseOthers"
            "BufferLineTogglePin"
            "BufferLineGroupClose"
          ];
          keys = [
            "<S-l>"
            "<S-h>"
            "]b"
            "[b"
            "<leader>bl"
            "<leader>bo"
            "<leader>bp"
            "<leader>bP"
          ];
        };
      };
      settings = {
        options = {
          diagnostics = "nvim_lsp";
          diagnostics_update_in_insert = false;
          mode = "buffers";
          close_icon = " ";
          buffer_close_icon = " ";
          modified_icon = "󰔯 ";
          separator_style = [
            ""
            ""
          ];
          always_show_bufferline = true;
          show_buffer_close_icons = false;
          show_close_icon = false;
          hover = {
            enabled = true;
            delay = 100;
            reveal = [ "close" ];
          };

          offsets = [
            {
              filetype = "neo-tree";
              text = "Neo-tree";
              highlight = "Directory";
              text_align = "left";
            }

            {
              buftype = "nofile";
              filetype = "snacks_layout_box";
              text = "Snacks";
              highlight = "Directory";
              text_align = "left";
              separator = false;
            }

            {
              buftype = "nofile";
              filetype = "trouble";
              text = "Trouble";
              highlight = "Directory";
              text_align = "right";
              separator = false;
            }
          ];
        };

      };
    };
  };

  keymaps = lib.mkIf config.plugins.bufferline.enable [
    {
      mode = "n";
      key = "]b";
      action = "<cmd>BufferLineCycleNext<cr>";
      options = {
        desc = "Cycle to next buffer";
      };
    }

    {
      mode = "n";
      key = "[b";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options = {
        desc = "Cycle to previous buffer";
      };
    }

    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>BufferLineCycleNext<cr>";
      options = {
        desc = "Cycle to next buffer";
      };

    }

    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>BufferLineCyclePrev<cr>";
      options = {
        desc = "Cycle to previous buffer";
      };
    }

    {
      mode = "n";
      key = "<leader>bl";
      action = "<cmd>BufferLineCloseLeft<cr>";
      options = {
        desc = "Delete buffers to the left";
      };
    }

    {
      mode = "n";
      key = "<leader>bo";
      action = "<cmd>BufferLineCloseOthers<cr>";
      options = {
        desc = "Delete other buffers";
      };
    }

    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>BufferLineTogglePin<cr>";
      options = {
        desc = "Toggle pin";
      };
    }

    {
      mode = "n";
      key = "<leader>bP";
      action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
      options = {
        desc = "Delete non-pinned buffers";
      };
    }
  ];
}

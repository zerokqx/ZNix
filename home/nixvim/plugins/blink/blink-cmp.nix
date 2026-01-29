{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;
    settings = {
      completion = {
        ghost_text.enabled = true;
        menu = {
          border = "rounded";
        };
        documentation = {
          auto_show = false;
          window = {
            border = "rounded";
          };
        };
      };
      signature = {
        enabled = false;
      };
      keymap = {
        preset = "enter";
      };
      sources = {
        default = [
          "lsp"
          "path"
          "snippets"

        ];
      };
      appearance = {
        use_nvim_cmp_as_default = true;
        kind_icons = {
          Class = "󱡠";
          Color = "󰏘";
          Constant = "󰏿";
          Constructor = "󰒓";
          Enum = "󰦨";
          EnumMember = "󰦨";
          Event = "󱐋";
          Field = "󰜢";
          File = "󰈔";
          Folder = "󰉋";
          Function = "󰊕";
          Interface = "󱡠";
          Keyword = "󰻾";
          Method = "󰊕";
          Module = "󰅩";
          Operator = "󰪚";
          Property = "󰖷";
          Reference = "󰬲";
          Snippet = "󱄽";
          Struct = "󱡠";
          Text = "󰉿";
          TypeParameter = "󰬛";
          Unit = "󰪚";
          Value = "󰦨";
          Variable = "";
        };
      };
      fuzzy = {
        sorts = [
          "exact"
          "score"
          "sort_text"
          "label"
        ];
      };

    };
  };
}

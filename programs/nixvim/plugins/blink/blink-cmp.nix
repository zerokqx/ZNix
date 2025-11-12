{
  plugins.cmp-calc.enable = true;
  plugins.blink-compat.enable = true;
  plugins.blink-cmp = {
    enable = true;
    settings = {
      completion = {
        menu = {
      show_source = true;
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
        enabled = true;
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
          "score"
          "kind"
          "label"
          "sort_text"
        ];
      };

    };
  };
}

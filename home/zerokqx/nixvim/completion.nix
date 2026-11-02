{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        ghost_text.enabled = true;
        accept = {
          auto_brackets = {
            enabled = true;
          };
        };
        menu = {
          border = "rounded";
          draw = {
            columns = [
              {
                __unkeyed-1 = "label";
              }
              {
                __unkeyed-1 = "kind_icon";
                __unkeyed-2 = "kind";
                gap = 1;
              }
              {
                __unkeyed-1 = "source_name";
              }
            ];
          };
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 100;
          window = {
            border = "rounded";
          };
        };
      };
      signature = {
        enabled = true;
        window = {
          border = "rounded";
        };
      };
      keymap = {
        preset = "enter";
        "<Tab>" = [
          "select_next"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "fallback"
        ];
        "<C-space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<C-e>" = [
          "hide"
          "fallback"
        ];
      };
      sources = {
        default = [
          "lsp"
          "path"
        ];
        providers = {
          lsp = {
            score_offset = 100;
          };
          buffer = {
            score_offset = -5;
          };
        };
      };
      appearance = {
        use_nvim_cmp_as_default = false;
        nerd_font_variant = "mono";
      };
      fuzzy = {
        implementation = "rust";
        sorts = [
          "exact"
          "score"
          "sort_text"
        ];
      };
    };
  };

  plugins.lsp.capabilities = lib.mkForce ''
    capabilities = require('blink.cmp').get_lsp_capabilities({
      textDocument = { completion = { completionItem = { snippetSupport = false } } },
    })
  '';
}

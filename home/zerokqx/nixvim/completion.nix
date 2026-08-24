{ lib, ... }:
{

  plugins.friendly-snippets.enable = true;

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
          border = "single";
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
            border = "single";
          };
        };
      };
      signature = {
        enabled = true;
        window = {
          border = "single";
        };
      };
      keymap = {
        preset = "enter";
        "<Tab>" = [
          "select_next"
          "snippet_forward"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "snippet_backward"
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
          "snippets"
          "buffer"
        ];
        providers = {
          lsp = {
            score_offset = 100;
          };
          snippets = {
            score_offset = -2;
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

  plugins.lsp.capabilities = lib.mkForce "require('blink.cmp').get_lsp_capabilities()";
}

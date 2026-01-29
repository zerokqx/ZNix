{ lib, ... }:
{
  plugins.blink-cmp = {
    enable = true;
    settings = {
      completion = {
        ghost_text.enabled = true;
        menu = {
          border = "rounded";
          draw = {
            components = {
              kind_icon = {
                ellipsis = false;
                text = lib.nixvim.mkRaw ''
                  function(ctx)
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, _ = require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then return mini_icon .. ctx.icon_gap end
                    end

                    local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                    return icon .. ctx.icon_gap
                  end
                '';
                highlight = lib.nixvim.mkRaw ''
                  function(ctx)
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, mini_hl = require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then return mini_hl end
                    end
                    return ctx.kind_hl
                  end
                '';
              };
              kind = {
                highlight = lib.nixvim.mkRaw ''
                  function(ctx)
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local mini_icon, mini_hl = require("mini.icons").get_icon(ctx.item.data.type, ctx.label)
                      if mini_icon then return mini_hl end
                    end
                    return ctx.kind_hl
                  end
                '';
              };
            };
          };
        };
        documentation = {
          auto_show = false;
          window = {
            border = "rounded";
          };
        };
      };
      signature.enabled = false;
      keymap.preset = "enter";
      sources.default = [
        "lsp"
        "path"
        "snippets"
      ];
      appearance.use_nvim_cmp_as_default = true;
      fuzzy.sorts = [
        "exact"
        "score"
        "sort_text"
        "label"
      ];
    };
  };
}

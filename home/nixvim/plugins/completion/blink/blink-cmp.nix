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
                    local function path_icon()
                      if not vim.tbl_contains({ "Path" }, ctx.source_name) then return nil end
                      if not (ctx.item and ctx.item.data) then return nil end

                      local category = ctx.item.data.type == "directory" and "directory" or "file"
                      return require("mini.icons").get(category, ctx.item.data.full_path or ctx.label)
                    end

                    local icon, _ = path_icon()
                    if icon then return icon .. ctx.icon_gap end

                    local lspkind_icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
                    return lspkind_icon .. ctx.icon_gap
                  end
                '';
                highlight = lib.nixvim.mkRaw ''
                  function(ctx)
                    local function path_hl()
                      if not vim.tbl_contains({ "Path" }, ctx.source_name) then return nil end
                      if not (ctx.item and ctx.item.data) then return nil end

                      local category = ctx.item.data.type == "directory" and "directory" or "file"
                      local _, hl = require("mini.icons").get(category, ctx.item.data.full_path or ctx.label)
                      return hl
                    end

                    local hl = path_hl()
                    if hl then return hl end
                    return ctx.kind_hl
                  end
                '';
              };
              kind = {
                highlight = lib.nixvim.mkRaw ''
                  function(ctx)
                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      if ctx.item and ctx.item.data then
                        local category = ctx.item.data.type == "directory" and "directory" or "file"
                        local _, mini_hl = require("mini.icons").get(category, ctx.item.data.full_path or ctx.label)
                        if mini_hl then return mini_hl end
                      end
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

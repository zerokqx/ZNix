{ lib, ... }:
{
  plugins.nvim-tree = {
    settings = {
      git = {
        enable = true;
        ignore = false;
      };

      renderer = {
        indent_width = 1;
        highlight_git = true;
        icons = {
          show.git = true;
          glyphs.git = {
            added = "+"; # staged new
            modified = "•"; # changed
            deleted = "×";
            untracked = "?";
            ignored = "·";
          };
        };
      };

      diagnostics.enable = true;

      view = {
        float = {
          enable = false;
          open_win_config = {
            relative = "editor";
            width = 40;
            height = 100;
            row = 0;
            col = 0;
          };
        };
      };

      update_focused_file.enable = true;

      on_attach = lib.nixvim.mkRaw ''
        function(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          api.config.mappings.default_on_attach(bufnr)

          vim.keymap.set("n", "s", api.node.open.edit, opts("Open"))
        end
      '';
    };
  };
}

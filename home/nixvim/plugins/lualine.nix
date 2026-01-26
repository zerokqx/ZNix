{ lib, ... }:
{
  plugins.lualine = {
    enable = true;
    settings =
      let
        separators = {
          right = ""; # ╭
          left = ""; # ╮
        };

      in
      {
        options = {
          always_divide_middle = true;
          globalstatus = true;
          icons_enable = true;
          section_separators = separators;
          disabled_filetypes = [
            "Outline"
            "neo-tree"
            "dashboard"
            "snacks_dashboard"
            "snacks_terminal"
          ];
        };
      };
  };
}

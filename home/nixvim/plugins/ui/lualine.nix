{ lib, ... }:
{
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        always_divide_middle = true;
        globalstatus = true;
        icons_enable = true;
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
        disabled_filetypes = [
          "Outline"
          "neo-tree"
          "dashboard"
          "ministarter"
          "snacks_dashboard"
        ];
      };
    };
  };
}

{ lib, ... }:
{
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        always_divide_middle = true;
        globalstatus = true;
        icons_enable = true;
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

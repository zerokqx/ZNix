{ ... }:
{
  plugins.lualine = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.event = "VimEnter";
    };
    settings = {
      options = {
        always_divide_middle = true;
        globalstatus = true;
        icons_enable = true;
        theme = "auto";
        component_separators = {
          left = "";
          right = "";
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
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [
          "branch"
          "diff"
        ];
        lualine_c = [
          {
            __unkeyed-1 = "filename";
            path = 1;
            symbols = {
              modified = " ●";
              readonly = " ";
            };
          }
        ];
        lualine_x = [
          "diagnostics"
          "encoding"
          "fileformat"
          "filetype"
        ];
        lualine_y = [ "progress" ];
        lualine_z = [ "location" ];
      };
      extensions = [
        "lazy"
        "trouble"
        "quickfix"
      ];
      refresh = {
        statusline = 250;
        tabline = 350;
        winbar = 350;
      };
    };
  };
}

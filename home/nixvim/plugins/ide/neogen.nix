{ config, lib, ... }:
{
  plugins.neogen = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings.cmd = "Neogen";
      settings.keys = [
        "<leader>cn"
      ];
    };
    settings = {
      languages = {
        lua = {
          template = {
            annotation_convention = "emmylua";
          };
        };
        python = {
          template = {
            annotation_convention = "numpydoc";
          };
        };
        typescript = {
          template = {
            annotation_convention = "tsdoc";
          };
        };
        javascript = {
          template = {
            annotation_convention = "jsdoc";
          };
        };
      };
      snippet_engine = "mini";
    };
  };
  keymaps = lib.mkIf config.plugins.neogen.enable [

    {

      mode = "n";
      key = "<leader>cn";
      action = ":Neogen<cr>";
      options = {
        silent = true;
        desc = "Neogen";
      };
    }
  ];
}

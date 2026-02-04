{ ... }:
{
  plugins.mini-surround = {
    lazyLoad = {
      enable = true;
      settings.keys = [
        "gsa"
        "gsd"
        "gsf"
        "gsF"
        "gsh"
        "gsr"
        "gsn"
      ];
    };
    enable = true;
    settings = {
      mappings = {
        add = "gsa";
        delete = "gsd";
        find = "gsf";
        find_left = "gsF";
        highlight = "gsh";
        replace = "gsr";
        update_n_lines = "gsn";
      };
    };
  };
}

{ lib, config, ... }:
{
  plugins.undotree = {

    enable = true;
    lazyLoad = {
      enable = true;
      settings.cmd = "UndotreeToggle";
    };
  };
  keymaps = lib.mkIf config.plugins.undotree.enable [
    {
      mode = [
        "n"
      ];
      key = "<leader>U";
      action = ":UndotreeToggle<cr>";
      options = {
        silent = true;
        desc = "Undotree toggle";

      };
    }
  ];

}

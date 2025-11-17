{ lib, config, ... }:
with lib;
{

  options.fileManager = mkOption {

    type = types.enum [
      "yazi"
      "mini-files"

    ];
    default = "yazi";
    description = "Choose which file manager plugin to enable";
  };

  config = mkMerge [
    (mkIf (config.fileManager == "yazi") {
      plugins.yazi.enable = true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Yazi<cr>";
          options = {
            desc = "Yazi toggle";
            silent = true;
          };
        }
      ];
    })

    (mkIf (config.fileManager == "mini-files") {
      plugins.mini-files.enable = true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>lua MiniFiles.open()<cr>";
          options = {
            desc = "MiniFiles toggle";
            silent = true;
          };
        }
      ];
    })
  ];
}

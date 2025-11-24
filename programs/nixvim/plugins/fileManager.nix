{ lib, config, ... }:
with lib;
{

  options.fileManager = mkOption {

    type = types.enum [
      "yazi"
      "mini-files"
      "snacks"
      "neotree"
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

    (mkIf (config.fileManager == "snacks") {

      plugins.snacks.settings.explorer.enabled = lib.mkForce true;
      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = ":lua Snacks.explorer()<CR>";
          options = {
            silent = true;
            desc = "Snacksplorer";
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
    (mkIf (config.fileManager == "neotree") {
      plugins.neo-tree.enable = true;
      plugins.neo-tree.lazyLoad.enable = true;
      plugins.neo-tree.lazyLoad.settings = {

        cmd = "Neotree";
        keys = [
          {
            __unkeyed-1 = "<leader>e"; # ключ (keybinding)
            __unkeyed-2 = "<cmd>Neotree toggle<cr>"; # действие
            desc = "Explorer NeoTree (root dir)";
            mode = "n"; # режим (например, "n" — normal, "v" — visual)
          }
        ];
      };
    })
  ];
}

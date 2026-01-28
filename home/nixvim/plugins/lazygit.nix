{ config, lib, ... }:
{

  plugins.lazygit.enable = true;
  keymaps = lib.mkIf config.plugins.lazygit.enable [
    {

      mode = [
        "n"
      ];
      key = "<leader>gz";
      action = ":LazyGit<cr>";
      options = {

        silent = true;
        desc = "LazyGit";

      };
    }
  ];

}

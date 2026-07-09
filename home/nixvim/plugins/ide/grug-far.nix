{ config, lib, ... }:
{
  plugins.grug-far = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings = {
        cmd = "GrugFar";
        keys = [
          "<leader>sr"
        ];
      };
    };
  };

  keymaps = lib.mkIf config.plugins.grug-far.enable [
    {
      mode = [ "n" "v" ];
      key = "<leader>sr";
      action = "<cmd>GrugFar<cr>";
      options = {
        silent = true;
        desc = "Search and Replace (GrugFar)";
      };
    }
  ];
}


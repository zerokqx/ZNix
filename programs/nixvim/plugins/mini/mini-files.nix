{ lib, config, ... }:

lib.mkIf (config.plugins.snacks.settings.explorer.enabled == false) {

  plugins.mini-files = {
    enable = true;
    settings = {
      options = {
        permanent_delete = false;
        use_as_default_explorer = true;
      };
      max_number = lib.nixvim.mkRaw "math.huge";
      preview = false;
      width_focus = 50;
      width_nofocus = 10;
      width_preview = 25;
    };
  };
  keymaps = [

    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>";
      options = {
        silent = true;
        desc = "File Explorer (mini.files)";
      };
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>lua MiniFiles.open()<cr>";
      options = {
        silent = true;
        desc = "File Explorer (mini.files)";
      };
    }
  ];
}

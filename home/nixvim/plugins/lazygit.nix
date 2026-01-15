{ lib, config, ... }:
{
  plugins.lazygit = {
    enable = true;
    settings = {
      config_file_path = lib.nixvim.emptyTable;
      floating_window_border_chars = [
        "╭"
        "─"
        "╮"
        "│"
        "╯"
        "─"
        "╰"
        "│"
      ];
      floating_window_scaling_factor = 0.9;
      floating_window_use_plenary = 0;
      floating_window_winblend = 0;
      use_custom_config_file_path = 0;
      use_neovim_remote = 1;
    };
  };
  keymaps = lib.mkIf config.plugins.lazygit.enable [
    {
      mode = "n";
      key = "<leader>gz";
      action = ":LazyGit<cr>";
      options = {
        silent = true;
        desc = "LazyGit open";
      };

    }
  ];
}

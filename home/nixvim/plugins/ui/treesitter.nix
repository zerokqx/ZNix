{ config, lib, ... }:

{
  plugins = {
    treesitter = {
      enable = true;
      settings = {
        highlight = {
          additional_vim_regex_highlighting = false;
          enable = true;
          disable.__raw = ''
            function(_, buf)
              local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
              return ok and stats and stats.size and stats.size > 192 * 1024
            end
          '';
        };
        incremental_selection.enable = true;
        indent.enable = true;
        sync_install = false;
      };
      nixvimInjections = true;
    };

    treesitter-context = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };
      settings = {
        max_lines = 3;
        min_window_height = 32;
        multiwindow = false;
        separator = "─";
      };
    };
  };

  keymaps = lib.mkIf config.plugins.treesitter-context.enable [
    {
      mode = "n";
      key = "<leader>uT";
      action = "<cmd>TSContextToggle<cr>";
      options.desc = "Treesitter Context toggle";
    }
  ];
}

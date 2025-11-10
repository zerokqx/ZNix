{ lib, config, ... }:

lib.mkIf (config.plugins.lspsaga.enable == false) {

  plugins.goto-preview = {
    enable = true;
    settings = {
      border = "rounded";
      relative = "editor";
      default_mappings = true;

      post_open_hook = {
        __raw = ''
          function(_, win)
            local function close_window()
              pcall(function()
                vim.api.nvim_win_close(win, true)
              end)
            end

            vim.keymap.set('n', '<Esc>', close_window, { buffer = true })
            vim.keymap.set('n', 'q', close_window, { buffer = true })
          end
        '';
      };
    };
  };
}

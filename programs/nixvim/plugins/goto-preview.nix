{
  plugins.goto-preview = {
    enable = true;
    settings = {

      border = "rounded"; # стиль рамки
      relative = "editor"; # позиционирование относительно экрана

      default_mappings = true;

      post_open_hook = {
        __raw = ''
          function(_, win)
            local function close_window()
              local success, err = pcall(function()
                vim.api.nvim_win_close(win, true)
              end)
              -- Ошибка перехвачена, ничего не выводим
            end
            vim.keymap.set('n', '<Esc>', close_window, { buffer = true })
            vim.keymap.set('n', 'q', close_window, { buffer = true })
          end
        '';
      };
    };
  };
}

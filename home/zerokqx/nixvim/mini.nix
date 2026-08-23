{ lib, ... }:
{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;

    modules = {
      # 1. Быстрое комментирование (gcc для строки, gc в visual)
      comment = {
        options = {
          custom_commentstring.__raw = ''
            function()
              return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
            end
          '';
        };
      };

      # 2. Базовые настройки редактора (Mini.basics)
      basics = {
        options = {
          basic = true;
          extra_ui = true;
          win_borders = "single";
        };
        mappings = {
          basic = true;
          option_toggle_prefix = "\\";
          windows = true; # Нативная навигация по сплитам Ctrl+hjkl и ресайз Ctrl+стрелки
          move_with_alt = true; # Перемещение курсора в Insert/Cmd/Term через Alt+hjkl
        };
        autocommands = {
          basic = true;
          relnum_in_visual_mode = true;
        };
      };

      # 3. Статус-бар (Mini.statusline)
      statusline = {
        use_icons = true;
      };

      # 4. Верхняя панель буферов (Mini.tabline)
      tabline = {
        show_icons = true;
      };

      # 5. Подсветка HEX цветов и ключевых слов TODO / FIXME / HACK / NOTE
      hipatterns = {
        highlighters = {
          hex_color.__raw = "require('mini.hipatterns').gen_highlighter.hex_color()";
          fixme = {
            pattern = "%f[%w]()FIXME()%f[%W]";
            group = "MiniHipatternsFixme";
          };
          hack = {
            pattern = "%f[%w]()HACK()%f[%W]";
            group = "MiniHipatternsHack";
          };
          todo = {
            pattern = "%f[%w]()TODO()%f[%W]";
            group = "MiniHipatternsTodo";
          };
          note = {
            pattern = "%f[%w]()NOTE()%f[%W]";
            group = "MiniHipatternsNote";
          };
        };
      };

      # 6. Умные текстовые объекты (daf - вся функция, cia - изменить аргумент, cib - внутри скобок)
      ai = {
        n_lines = 500;
        search_method = "cover_or_next";
      };

      # 7. Перемещение строк и блоков кода через Alt + Стрелки
      move = {
        mappings = {
          left = "<M-Left>";
          right = "<M-Right>";
          down = "<M-Down>";
          up = "<M-Up>";
          line_left = "<M-Left>";
          line_right = "<M-Right>";
          line_down = "<M-Down>";
          line_up = "<M-Up>";
        };
      };

      # 8. Разворачивание/сворачивание аргументов и массивов (хоткей gS)
      splitjoin = {
        mappings = {
          toggle = "gS";
        };
      };

      # 9. Интерактивное выравнивание кода по колонкам (хоткеи ga / gA)
      align = {
        mappings = {
          start = "ga";
          start_with_preview = "gA";
        };
      };

      # 10. Удобная навигация вперед/назад через [ и ]
      bracketed = {
        buffer = {
          suffix = "b";
          options = { };
        };
        comment = {
          suffix = "c";
          options = { };
        };
        conflict = {
          suffix = "x";
          options = { };
        };
        diagnostic = {
          suffix = "d";
          options = { };
        };
        file = {
          suffix = "f";
          options = { };
        };
        quickfix = {
          suffix = "q";
          options = { };
        };
        treesitter = {
          suffix = "t";
          options = { };
        };
        undo = {
          suffix = "u";
          options = { };
        };
      };

      # 11. Автоматические пары скобок и кавычек
      pairs = { };

      # 12. Быстрое обрамление текста (surround)
      surround = { };

      # 13. Иконки файлов
      icons = { };

      # 14. Сверхлегкий движок сниппетов (Mini.snippets)
      snippets = {
        snippets.__raw = "{ require('mini.snippets').gen_loader.from_lang() }";
        mappings = {
          expand = "<C-j>";
          jump_next = "<C-l>";
          jump_prev = "<C-h>";
          stop = "<C-c>";
        };
      };
    };
  };

  # Цвета для ключевых слов MiniHipatterns
  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#1a1b26", bg = "#f7768e", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack",  { fg = "#1a1b26", bg = "#e0af68", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo",  { fg = "#1a1b26", bg = "#7aa2f7", bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote",  { fg = "#1a1b26", bg = "#9ece6a", bold = true })
  '';
}

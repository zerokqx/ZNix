{ lib, ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      # 1. Файловый менеджер (замена mini.files)
      explorer = {
        enabled = true;
        replace_netrw = true;
      };

      # 2. Нечеткий поиск (замена mini.pick & mini.extra)
      picker = {
        enabled = true;
        ui_select = true; # Заменяет vim.ui.select
        sources = {
          explorer = {
            auto_close = true;
            layout = {
              preset = "default";
              preview = true;
            };
          };
        };
      };

      # 3. Индикаторы отступов и Scope (замена mini.indentscope)
      indent = {
        enabled = true;
        animate = {
          enabled = false; # Меньше нагрузки на CPU и 0 фризов
        };
        scope = {
          enabled = true;
          underline = false;
        };
        chunk = {
          enabled = true;
        };
      };

      # 4. Область видимости
      scope = {
        enabled = true;
      };

      # 5. Окно ввода (замена mini.input / vim.ui.input)
      input = {
        enabled = true;
      };

      # 6. Всплывающие уведомления (замена mini.notify)
      notifier = {
        enabled = true;
        timeout = 3000;
      };

      # 7. Стартовый дашборд (замена mini.starter)
      dashboard = {
        enabled = true;
        sections = [
          { section = "header"; }
          {
            icon = " ";
            title = "Быстрый доступ";
            section = "keys";
            indent = 2;
            padding = 1;
            gap = 1;
          }
          {
            icon = " ";
            title = "Недавние файлы";
            section = "recent_files";
            indent = 2;
            padding = 1;
          }
          {
            icon = " ";
            title = "Проекты";
            section = "projects";
            indent = 2;
            padding = 1;
          }
          {
            align = "center";
            padding = 1;
            text.__raw = ''{ { "⚡ ZNix • Neovim Pure Environment", hl = "footer" } }'';
          }
        ];
        preset = {
          header = ''
  ███████╗███╗   ██╗██╗██╗  ██╗
  ╚══███╔╝████╗  ██║██║╚██╗██╔╝
    ███╔╝ ██╔██╗ ██║██║ ╚███╔╝ 
   ███╔╝  ██║╚██╗██║██║ ██╔██╗ 
  ███████╗██║ ╚████║██║██╔╝ ██╗
  ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
          '';
          keys = [
            {
              icon = " ";
              key = "f";
              desc = "Найти файл";
              action = ":lua Snacks.dashboard.pick('files')";
            }
            {
              icon = " ";
              key = "n";
              desc = "Новый файл";
              action = ":ene | startinsert";
            }
            {
              icon = " ";
              key = "g";
              desc = "Найти текст (Grep)";
              action = ":lua Snacks.dashboard.pick('live_grep')";
            }
            {
              icon = " ";
              key = "r";
              desc = "Недавние файлы";
              action = ":lua Snacks.dashboard.pick('oldfiles')";
            }
            {
              icon = " ";
              key = "c";
              desc = "Конфигурация ZNix";
              action = ":lua Snacks.dashboard.pick('files', { cwd = '/home/zerok/projects/ZNix' })";
            }
            {
              icon = " ";
              key = "q";
              desc = "Выход";
              action = ":qa";
            }
          ];
        };
      };

      # 8. Закрытие буферов без поломки окон (замена mini.bufremove)
      bufdelete = {
        enabled = true;
      };

      # 9. Подсветка слова под курсором (замена mini.cursorword)
      words = {
        enabled = true;
        debounce = 100;
      };

      # 10. Встроенный терминал (замена toggleterm)
      terminal = {
        enabled = true;
      };

      # 11. Git интеграции (замена mini.git / mini.diff)
      lazygit = {
        enabled = true;
      };
      git = {
        enabled = true;
      };
      gitbrowse = {
        enabled = true;
      };

      # 12. Оптимизации и QoL фичи
      bigfile = {
        enabled = true;
      };
      quickfile = {
        enabled = true;
      };
      scroll = {
        enabled = true;
        animate = {
          duration = {
            step = 15;
            total = 150;
          };
        };
      };
      zen = {
        enabled = true;
      };
      scratch = {
        enabled = true;
      };
      rename = {
        enabled = true;
      };
      statuscolumn = {
        enabled = true;
      };
    };
  };

  keymaps = [
    # Файловый проводник (Snacks Explorer)
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>lua Snacks.explorer()<CR>";
      options = {
        silent = true;
        desc = "Файловый проводник (Snacks)";
      };
    }

    # Поиск и файлы (Snacks Picker)
    {
      mode = "n";
      key = "<leader><space>";
      action = "<cmd>lua Snacks.picker.files()<CR>";
      options = {
        silent = true;
        desc = "Поиск файлов в проекте";
      };
    }
    {
      mode = "n";
      key = "<leader>sf";
      action = "<cmd>lua Snacks.picker.files()<CR>";
      options = {
        silent = true;
        desc = "Поиск файлов";
      };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>lua Snacks.picker.files()<CR>";
      options = {
        silent = true;
        desc = "Поиск файлов";
      };
    }
    {
      mode = "n";
      key = "<leader>sp";
      action = "<cmd>lua Snacks.picker.projects()<CR>";
      options = {
        silent = true;
        desc = "Проекты";
      };
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>lua Snacks.picker.recent()<CR>";
      options = {
        silent = true;
        desc = "Недавние файлы";
      };
    }
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>lua Snacks.picker.grep()<CR>";
      options = {
        silent = true;
        desc = "Поиск текста (Grep)";
      };
    }
    {
      mode = "n";
      key = "<leader>sg";
      action = "<cmd>lua Snacks.picker.grep()<CR>";
      options = {
        silent = true;
        desc = "Grep";
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>sw";
      action = "<cmd>lua Snacks.picker.grep_word()<CR>";
      options = {
        silent = true;
        desc = "Поиск слова под курсором";
      };
    }
    {
      mode = "n";
      key = "<leader>,";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
      options = {
        silent = true;
        desc = "Буферы";
      };
    }
    {
      mode = "n";
      key = "<leader>sb";
      action = "<cmd>lua Snacks.picker.buffers()<CR>";
      options = {
        silent = true;
        desc = "Поиск по буферам";
      };
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
      options = {
        silent = true;
        desc = "Все ошибки проекта";
      };
    }
    {
      mode = "n";
      key = "<leader>sD";
      action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
      options = {
        silent = true;
        desc = "Ошибки текущего буфера";
      };
    }
    {
      mode = "n";
      key = "<leader>sk";
      action = "<cmd>lua Snacks.picker.keymaps()<CR>";
      options = {
        silent = true;
        desc = "Горячие клавиши";
      };
    }
    {
      mode = "n";
      key = "<leader>shc";
      action = "<cmd>lua Snacks.picker.command_history()<CR>";
      options = {
        silent = true;
        desc = "История команд";
      };
    }
    {
      mode = "n";
      key = "<leader>su";
      action = "<cmd>lua Snacks.picker.undo()<CR>";
      options = {
        silent = true;
        desc = "История отмен (Undo)";
      };
    }
    {
      mode = "n";
      key = "<leader>s\"";
      action = "<cmd>lua Snacks.picker.registers()<CR>";
      options = {
        silent = true;
        desc = "Регистры";
      };
    }

    # Управление буферами (Snacks Bufdelete)
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>lua Snacks.bufdelete()<CR>";
      options = {
        silent = true;
        desc = "Закрыть буфер";
      };
    }
    {
      mode = "n";
      key = "<leader>bo";
      action = "<cmd>lua Snacks.bufdelete.other()<CR>";
      options = {
        silent = true;
        desc = "Закрыть все остальные буферы";
      };
    }
    {
      mode = "n";
      key = "<leader>bO";
      action = "<cmd>lua Snacks.bufdelete.all()<CR>";
      options = {
        silent = true;
        desc = "Закрыть все буферы";
      };
    }

    # Git (Snacks Git & Lazygit)
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>lua Snacks.lazygit()<CR>";
      options = {
        silent = true;
        desc = "Lazygit";
      };
    }
    {
      mode = "n";
      key = "<leader>gl";
      action = "<cmd>lua Snacks.picker.git_log()<CR>";
      options = {
        silent = true;
        desc = "Git Log";
      };
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>lua Snacks.picker.git_branches()<CR>";
      options = {
        silent = true;
        desc = "Git Branches";
      };
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>lua Snacks.picker.git_diff()<CR>";
      options = {
        silent = true;
        desc = "Git Diff";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>gB";
      action = "<cmd>lua Snacks.gitbrowse()<CR>";
      options = {
        silent = true;
        desc = "Открыть файл в браузере (Git)";
      };
    }

    # Уведомления (Snacks Notifier)
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>lua Snacks.notifier.show_history()<CR>";
      options = {
        silent = true;
        desc = "История уведомлений";
      };
    }
    {
      mode = "n";
      key = "<leader>un";
      action = "<cmd>lua Snacks.notifier.hide()<CR>";
      options = {
        silent = true;
        desc = "Скрыть уведомления";
      };
    }

    # Навигация по LSP ссылкам слов (Snacks Words)
    {
      mode = [
        "n"
        "t"
      ];
      key = "]]";
      action = "<cmd>lua Snacks.words.jump(vim.v.count1)<CR>";
      options = {
        silent = true;
        desc = "Следующее вхождение слова";
      };
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "[[";
      action = "<cmd>lua Snacks.words.jump(-vim.v.count1)<CR>";
      options = {
        silent = true;
        desc = "Предыдущее вхождение слова";
      };
    }

    # Терминал (Snacks Terminal)
    {
      mode = [
        "n"
        "t"
      ];
      key = "<C-/>";
      action = "<cmd>lua Snacks.terminal.toggle()<CR>";
      options = {
        silent = true;
        desc = "Открыть/скрыть терминал";
      };
    }
    {
      mode = "n";
      key = "<leader>tt";
      action = "<cmd>lua Snacks.terminal.toggle()<CR>";
      options = {
        silent = true;
        desc = "Терминал (Toggle)";
      };
    }

    # QoL фичи (Zen, Scratch, Rename)
    {
      mode = "n";
      key = "<leader>z";
      action = "<cmd>lua Snacks.zen()<CR>";
      options = {
        silent = true;
        desc = "Zen режим";
      };
    }
    {
      mode = "n";
      key = "<leader>Z";
      action = "<cmd>lua Snacks.zen.zoom()<CR>";
      options = {
        silent = true;
        desc = "Zoom окна";
      };
    }
    {
      mode = "n";
      key = "<leader>.";
      action = "<cmd>lua Snacks.scratch()<CR>";
      options = {
        silent = true;
        desc = "Scratch буфер";
      };
    }
    {
      mode = "n";
      key = "<leader>S";
      action = "<cmd>lua Snacks.scratch.select()<CR>";
      options = {
        silent = true;
        desc = "Выбрать Scratch буфер";
      };
    }
    {
      mode = "n";
      key = "<leader>cR";
      action = "<cmd>lua Snacks.rename.rename_file()<CR>";
      options = {
        silent = true;
        desc = "Переименовать файл (LSP)";
      };
    }

    # LSP Pickers
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
      options = {
        silent = true;
        desc = "Перейти к определению";
      };
    }
    {
      mode = "n";
      key = "gI";
      action = "<cmd>lua Snacks.picker.lsp_implementations()<CR>";
      options = {
        silent = true;
        desc = "Реализации";
      };
    }
    {
      mode = "n";
      key = "gy";
      action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
      options = {
        silent = true;
        desc = "Тип определения";
      };
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
      options = {
        silent = true;
        desc = "LSP символы файла";
      };
    }
    {
      mode = "n";
      key = "<leader>sS";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
      options = {
        silent = true;
        desc = "LSP символы проекта";
      };
    }
  ];
}

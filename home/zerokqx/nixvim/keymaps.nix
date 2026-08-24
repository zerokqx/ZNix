{ lib, ... }:
{
  keymaps = [
    {
      key = ";";
      action = ":";
    }

    {
      mode = "n";
      key = "q";
      action = "<Nop>";
      options = {
        silent = true;
        desc = "Отключить запись макросов";
      };
    }
    {
      mode = "n";
      key = "Q";
      action = "<Nop>";
      options = {
        silent = true;
        desc = "Отключить режим Ex / макросы";
      };
    }

    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<CR>";
      options = {
        silent = true;
        desc = "Предыдущий буфер (влево)";
      };
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options = {
        silent = true;
        desc = "Следующий буфер (вправо)";
      };
    }
    {
      mode = "n";
      key = "<leader>wa";
      action = ":wa! | echo 'Все сохранено!'<cr>";
      options = {
        silent = true;
        desc = "Сохранить все буферы";
      };
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = ":qa!<CR>";
      options = {
        silent = true;
        desc = "Выйти из Neovim";
      };
    }

    {
      mode = "n";
      key = "<leader>wd";
      action = ":close<CR>";
      options = {
        silent = true;
        desc = "Закрыть текущее окно";
      };
    }
    {
      mode = "n";
      key = "<leader>wo";
      action = ":only<CR>";
      options = {
        silent = true;
        desc = "Закрыть все окна кроме текущего";
      };
    }
    {
      mode = "n";
      key = "<leader>wq";
      action = ":quit<CR>";
      options = {
        silent = true;
        desc = "Выйти из окна";
      };
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = ":vsplit<CR>";
      options = {
        silent = true;
        desc = "Вертикальный сплит";
      };
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = ":split<CR>";
      options = {
        silent = true;
        desc = "Горизонтальный сплит";
      };
    }
    {
      mode = "n";
      key = "<leader>wr";
      action = "<C-w>r";
      options = {
        silent = true;
        desc = "Поменять окна местами";
      };
    }
    {
      mode = "n";
      key = "<leader>w=";
      action = "<C-w>=";
      options = {
        silent = true;
        desc = "Выровнять окна";
      };
    }

    {
      mode = "t";
      key = "<C-h>";
      action = "<C-\\><C-n><C-w>h";
      options = {
        silent = true;
        desc = "Перейти в окно слева из терминала";
      };
    }
    {
      mode = "t";
      key = "<C-j>";
      action = "<C-\\><C-n><C-w>j";
      options = {
        silent = true;
        desc = "Перейти в окно снизу из терминала";
      };
    }
    {
      mode = "t";
      key = "<C-k>";
      action = "<C-\\><C-n><C-w>k";
      options = {
        silent = true;
        desc = "Перейти в окно сверху из терминала";
      };
    }
    {
      mode = "t";
      key = "<C-l>";
      action = "<C-\\><C-n><C-w>l";
      options = {
        silent = true;
        desc = "Перейти в окно справа из терминала";
      };
    }

    {
      mode = "n";
      key = "<A-h>";
      action = "<C-w><";
      options = {
        silent = true;
        desc = "Уменьшить ширину окна";
      };
    }
    {
      mode = "n";
      key = "<A-l>";
      action = "<C-w>>";
      options = {
        silent = true;
        desc = "Увеличить ширину окна";
      };
    }
    {
      mode = "n";
      key = "<A-j>";
      action = "<C-w>+";
      options = {
        silent = true;
        desc = "Увеличить высоту окна";
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<C-w>-";
      options = {
        silent = true;
        desc = "Уменьшить высоту окна";
      };
    }

    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options = {
        silent = true;
        desc = "Code Action (Действия с кодом)";
      };
    }
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options = {
        silent = true;
        desc = "Rename (Переименовать символ)";
      };
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options = {
        silent = true;
        desc = "Rename (Альтернативный хоткей)";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format({ lsp_fallback = true })<CR>";
      options = {
        silent = true;
        desc = "Format (Форматировать файл / блок)";
      };
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options = {
        silent = true;
        desc = "Line Diagnostics (Ошибки в строке)";
      };
    }
    {
      mode = "n";
      key = "<leader>cD";
      action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
      options = {
        silent = true;
        desc = "Buffer Diagnostics (Все ошибки буфера)";
      };
    }
    {
      mode = "n";
      key = "<leader>cs";
      action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
      options = {
        silent = true;
        desc = "Document Symbols (Символы в файле)";
      };
    }
    {
      mode = "n";
      key = "<leader>cS";
      action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
      options = {
        silent = true;
        desc = "Workspace Symbols (Символы в проекте)";
      };
    }
    {
      mode = "n";
      key = "<leader>ch";
      action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
      options = {
        silent = true;
        desc = "Signature Help (Подсказка сигнатуры)";
      };
    }
    {
      mode = "n";
      key = "<leader>ci";
      action = "<cmd>lua vim.lsp.buf.incoming_calls()<CR>";
      options = {
        silent = true;
        desc = "Incoming Calls (Входящие вызовы)";
      };
    }
    {
      mode = "n";
      key = "<leader>co";
      action = "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>";
      options = {
        silent = true;
        desc = "Outgoing Calls (Исходящие вызовы)";
      };
    }
    {
      mode = "n";
      key = "<leader>cl";
      action = "<cmd>LspInfo<CR>";
      options = {
        silent = true;
        desc = "LSP Info (Информация о LSP)";
      };
    }

    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options = {
        silent = true;
        desc = "Go to Definition";
      };
    }
    {
      mode = "n";
      key = "gtd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options = {
        silent = true;
        desc = "Go to Definition (gt)";
      };
    }
    {
      mode = "n";
      key = "gD";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      options = {
        silent = true;
        desc = "Go to Declaration";
      };
    }
    {
      mode = "n";
      key = "gtD";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      options = {
        silent = true;
        desc = "Go to Declaration (gt)";
      };
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      options = {
        silent = true;
        desc = "Go to Implementation";
      };
    }
    {
      mode = "n";
      key = "gti";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
      options = {
        silent = true;
        desc = "Go to Implementation (gt)";
      };
    }
    {
      mode = "n";
      key = "gy";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
      options = {
        silent = true;
        desc = "Go to Type Definition";
      };
    }
    {
      mode = "n";
      key = "gty";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
      options = {
        silent = true;
        desc = "Go to Type Definition (gt)";
      };
    }
    {
      mode = "n";
      key = "gtt";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
      options = {
        silent = true;
        desc = "Go to Type Definition (gtt)";
      };
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
      options = {
        silent = true;
        desc = "Go to References";
      };
    }
    {
      mode = "n";
      key = "gtr";
      action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
      options = {
        silent = true;
        desc = "Go to References (gt)";
      };
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options = {
        silent = true;
        desc = "Hover Documentation (Документация)";
      };
    }

    {
      mode = "n";
      key = "]h";
      action = "<cmd>Gitsigns next_hunk<CR>";
      options = {
        silent = true;
        desc = "Следующий Git Hunk";
      };
    }
    {
      mode = "n";
      key = "[h";
      action = "<cmd>Gitsigns prev_hunk<CR>";
      options = {
        silent = true;
        desc = "Предыдущий Git Hunk";
      };
    }
    {
      mode = "n";
      key = "]c";
      action = "<cmd>Gitsigns next_hunk<CR>";
      options = {
        silent = true;
        desc = "Следующий Git Hunk";
      };
    }
    {
      mode = "n";
      key = "[c";
      action = "<cmd>Gitsigns prev_hunk<CR>";
      options = {
        silent = true;
        desc = "Предыдущий Git Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>gh";
      action = "<cmd>Gitsigns preview_hunk<CR>";
      options = {
        silent = true;
        desc = "Превью Git Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = "<cmd>Gitsigns preview_hunk<CR>";
      options = {
        silent = true;
        desc = "Превью Git Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>hs";
      action = "<cmd>Gitsigns stage_hunk<CR>";
      options = {
        silent = true;
        desc = "Застейджить Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>hr";
      action = "<cmd>Gitsigns reset_hunk<CR>";
      options = {
        silent = true;
        desc = "Сбросить Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
      options = {
        silent = true;
        desc = "Переключить Git Blame строки";
      };
    }

    {
      mode = [
        "n"
        "i"
        "t"
      ];
      key = "<C-S-?>";
      action.__raw = ''
        function()
          local file = vim.api.nvim_get_runtime_file("doc/cheatsheet.txt", false)[1]
          if not file or file == "" or vim.fn.filereadable(file) == 0 then
            file = vim.fn.expand("~/projects/ZNix/docs/cheatsheet.txt")
          end
          Snacks.win({
            file = file,
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " ⚡ ZNix Neovim Cheat Sheet & Keymaps ⚡ ",
            title_pos = "center",
            backdrop = 60,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "no",
              statuscolumn = "",
              number = false,
              relativenumber = false,
            },
            keys = {
              q = "close",
              ["<Esc>"] = "close",
            },
          })
        end
      '';
      options = {
        silent = true;
        desc = "Открыть Cheat Sheet (Справка по хоткеям)";
      };
    }
    {
      mode = [
        "n"
        "i"
        "t"
      ];
      key = "<C-?>";
      action.__raw = ''
        function()
          local file = vim.api.nvim_get_runtime_file("doc/cheatsheet.txt", false)[1]
          if not file or file == "" or vim.fn.filereadable(file) == 0 then
            file = vim.fn.expand("~/projects/ZNix/docs/cheatsheet.txt")
          end
          Snacks.win({
            file = file,
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " ⚡ ZNix Neovim Cheat Sheet & Keymaps ⚡ ",
            title_pos = "center",
            backdrop = 60,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "no",
              statuscolumn = "",
              number = false,
              relativenumber = false,
            },
            keys = {
              q = "close",
              ["<Esc>"] = "close",
            },
          })
        end
      '';
      options = {
        silent = true;
        desc = "Открыть Cheat Sheet (Справка по хоткеям)";
      };
    }
    {
      mode = [
        "n"
        "i"
        "t"
      ];
      key = "<C-_>";
      action.__raw = ''
        function()
          local file = vim.api.nvim_get_runtime_file("doc/cheatsheet.txt", false)[1]
          if not file or file == "" or vim.fn.filereadable(file) == 0 then
            file = vim.fn.expand("~/projects/ZNix/docs/cheatsheet.txt")
          end
          Snacks.win({
            file = file,
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " ⚡ ZNix Neovim Cheat Sheet & Keymaps ⚡ ",
            title_pos = "center",
            backdrop = 60,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "no",
              statuscolumn = "",
              number = false,
              relativenumber = false,
            },
            keys = {
              q = "close",
              ["<Esc>"] = "close",
            },
          })
        end
      '';
      options = {
        silent = true;
        desc = "Открыть Cheat Sheet (Справка по хоткеям)";
      };
    }
    {
      mode = "n";
      key = "<leader>?";
      action.__raw = ''
        function()
          local file = vim.api.nvim_get_runtime_file("doc/cheatsheet.txt", false)[1]
          if not file or file == "" or vim.fn.filereadable(file) == 0 then
            file = vim.fn.expand("~/projects/ZNix/docs/cheatsheet.txt")
          end
          Snacks.win({
            file = file,
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " ⚡ ZNix Neovim Cheat Sheet & Keymaps ⚡ ",
            title_pos = "center",
            backdrop = 60,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "no",
              statuscolumn = "",
              number = false,
              relativenumber = false,
            },
            keys = {
              q = "close",
              ["<Esc>"] = "close",
            },
          })
        end
      '';
      options = {
        silent = true;
        desc = "Открыть Cheat Sheet (Справка по хоткеям)";
      };
    }
  ];
}

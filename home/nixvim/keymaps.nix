{ lib, ... }:
{
  keymaps = [
    {
      key = ";";
      action = ":";
    }

    {
      mode = "n";
      key = "<leader>cd";
      action = ":CustomDiagnosticCommand<cr>";
      options = {
        silent = true;
        desc = "Diagnostic Float";
      };
    }
    {

      mode = [
        "n"
        "i"
      ];
      key = "<C-s>";
      action = ":w<cr>";
      options = {
        silent = true;
        desc = "Save";

      };
    }
    {
      mode = "n";
      key = "<leader>wa";
      action = ":wa! | echo 'Все сохранено!'<cr>";
      options = {
        silent = true;
        desc = "Write all";
      };
    }

    {
      mode = "n";
      key = "<leader>qq";
      action = ":qa!<CR>";
      options = {
        silent = true;
        desc = "Выйти из ZNvim";
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
      key = "<leader>p";
      action = "<cmd>Snacks.picker.cliphist()<CR>";
      options = {
        silent = true;
        desc = "История копирования";
      };
    }

    {
      mode = "n";
      key = "q";
      action = "<Nop>";
      options = {
        noremap = true;
        silent = true;
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
      key = "<leader>wh";
      action = "<C-w>h";
      options = {
        silent = true;
        desc = "Переключиться на окно слева";
      };
    }
    {
      mode = "n";
      key = "<leader>wj";
      action = "<C-w>j";
      options = {
        silent = true;
        desc = "Переключиться на окно снизу";
      };
    }
    {
      mode = "n";
      key = "<leader>wk";
      action = "<C-w>k";
      options = {
        silent = true;
        desc = "Переключиться на окно сверху";
      };
    }
    {
      mode = "n";
      key = "<leader>wl";
      action = "<C-w>l";
      options = {
        silent = true;
        desc = "Переключиться на окно справа";
      };
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = ":vsplit<CR>";
      options = {
        silent = true;
        desc = "Вертикальное разделение окна";
      };
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = ":split<CR>";
      options = {
        silent = true;
        desc = "Горизонтальное разделение окна";
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
        desc = "Равномерно распределить окна";
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
      mode = "n";
      key = "K";
      action = lib.nixvim.mkRaw ''
        function()
          local ok, ufo = pcall(require, "ufo")
          if ok then
            local winid = ufo.peekFoldedLinesUnderCursor()
            if winid then
              return
            end
          end
          vim.lsp.buf.hover({ border = "rounded", winblend = 0 })
        end
      '';
      options = {
        silent = true;
        desc = "LSP Hover";
      };
    }
    {
      mode = "n";
      key = "<leader>ch";
      action = lib.nixvim.mkRaw ''
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          local has_provider = false
          for _, client in ipairs(clients) do
            local cap = client.server_capabilities or {}
            if cap.inlayHintProvider then
              has_provider = true
              break
            end
          end

          if not has_provider then
            vim.notify("Inlay hints are not supported in this buffer", vim.log.levels.WARN)
            return
          end

          local ih = vim.lsp.inlay_hint
          if type(ih) == "table" and type(ih.enable) == "function" then
            local enabled = false
            if type(ih.is_enabled) == "function" then
              local ok_new, val_new = pcall(ih.is_enabled, { bufnr = bufnr })
              if ok_new then
                enabled = val_new
              else
                local ok_old, val_old = pcall(ih.is_enabled, bufnr)
                if ok_old then
                  enabled = val_old
                end
              end
            end
            local ok_set = pcall(ih.enable, not enabled, { bufnr = bufnr })
            if not ok_set then
              pcall(ih.enable, bufnr, not enabled)
            end
            return
          end

          if vim.lsp.buf and type(vim.lsp.buf.inlay_hint) == "function" then
            local enabled = vim.b[bufnr].inlay_hints_enabled == true
            local next_state = not enabled
            local ok_legacy = pcall(vim.lsp.buf.inlay_hint, bufnr, next_state)
            if ok_legacy then
              vim.b[bufnr].inlay_hints_enabled = next_state
            end
          end
        end
      '';
      options = {
        silent = true;
        desc = "Toggle Inline Hints";
      };
    }
  ];
}

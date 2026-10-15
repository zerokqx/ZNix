{ ... }:
{
  extraConfigLua = ''
    -- Нативный автосейв с дебоунсом 500мс
    local autosave_timer = nil
    local function znix_debounced_save(buf)
      if autosave_timer then
        autosave_timer:stop()
        autosave_timer:close()
        autosave_timer = nil
      end
      autosave_timer = vim.uv.new_timer()
      autosave_timer:start(500, 0, vim.schedule_wrap(function()
        if autosave_timer then
          autosave_timer:stop()
          autosave_timer:close()
          autosave_timer = nil
        end
        if vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].modified
          and vim.bo[buf].buftype == ""
          and vim.api.nvim_buf_get_name(buf) ~= ""
          and not vim.bo[buf].readonly
        then
          pcall(vim.api.nvim_buf_call, buf, function()
            vim.cmd("silent! noautocmd write")
          end)
        end
      end))
    end

    vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("ZnixAutoSave", { clear = true }),
      callback = function(args)
        znix_debounced_save(args.buf)
      end,
    })

    -- Автоматическое закрытие и удаление дашборда при открытии любого буфера
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "alpha", "starter", "ministarter" },
      callback = function(args)
        vim.bo[args.buf].bufhidden = "wipe"
      end,
    })

    -- Автоматическое включение inlay hints и подсветка символа под курсором при подключении LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("ZnixLspAttach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Inlay hints (типы как в RustRover)
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end

        -- Подсветка всех вхождений символа под курсором
        if client:supports_method("textDocument/documentHighlight") then
          local hl_group = vim.api.nvim_create_augroup("ZnixLspHighlight_" .. args.buf, { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = hl_group,
            buffer = args.buf,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = hl_group,
            buffer = args.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    -- Сворачивание тестов в Rust по умолчанию (модули #[cfg(test)], mod tests/test и тестовые функции)
    local function znix_get_rust_test_nodes(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
        return {}, {}
      end
      local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "rust")
      if not ok or not parser then return {}, {} end

      local tree = parser:parse()[1]
      if not tree then return {}, {} end
      local root = tree:root()

      local function get_node_text(node)
        return vim.treesitter.get_node_text(node, bufnr)
      end

      local function has_test_attr(node)
        local prev = node:prev_sibling()
        while prev and prev:type() == "attribute_item" do
          local text = get_node_text(prev)
          if text:match("test") or text:match("quickcheck") then
            return true
          end
          prev = prev:prev_sibling()
        end
        return false
      end

      local function is_test_node(node)
        local ntype = node:type()
        if ntype == "mod_item" then
          for child in node:iter_children() do
            if child:type() == "identifier" then
              local name = get_node_text(child)
              if name == "test" or name == "tests" then
                return true
              end
            end
          end
          return has_test_attr(node)
        elseif ntype == "function_item" then
          return has_test_attr(node)
        end
        return false
      end

      local all_lines = {}
      local top_lines = {}

      local function find_nodes(node, is_top)
        if is_test_node(node) then
          local srow, _, _, _ = node:range()
          local line = srow + 1
          table.insert(all_lines, line)
          if is_top then
            table.insert(top_lines, line)
          end
          is_top = false
        end
        for child in node:iter_children() do
          find_nodes(child, is_top)
        end
      end

      find_nodes(root, true)
      table.sort(all_lines, function(a, b) return a > b end)
      return all_lines, top_lines
    end

    local function znix_fold_rust_tests(bufnr, winid)
      local all_lines, _ = znix_get_rust_test_nodes(bufnr)
      if #all_lines == 0 then return end

      local target_wins = winid and { winid } or vim.fn.win_findbuf(bufnr)
      for _, win in ipairs(target_wins) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_call(win, function()
            for _, line in ipairs(all_lines) do
              vim.cmd(string.format("silent! %dfoldclose", line))
            end
          end)
        end
      end
    end

    _G.znix_toggle_rust_tests = function(bufnr, winid)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      winid = winid or vim.api.nvim_get_current_win()
      local all_lines, top_lines = znix_get_rust_test_nodes(bufnr)
      if #all_lines == 0 then
        if Snacks and Snacks.notify then
          Snacks.notify.warn("Тесты не найдены в файле", { title = "Rust Tests" })
        end
        return
      end

      local any_top_folded = false
      for _, line in ipairs(top_lines) do
        if vim.fn.foldclosed(line) ~= -1 then
          any_top_folded = true
          break
        end
      end

      vim.api.nvim_win_call(winid, function()
        if any_top_folded then
          for _, line in ipairs(all_lines) do
            vim.cmd(string.format("silent! %dfoldopen!", line))
          end
        else
          for _, line in ipairs(all_lines) do
            vim.cmd(string.format("silent! %dfoldclose", line))
          end
        end
      end)

      if Snacks and Snacks.notify then
        if any_top_folded then
          Snacks.notify.info("Тесты развёрнуты", { title = "Rust Tests" })
        else
          Snacks.notify.info("Тесты свёрнуты", { title = "Rust Tests" })
        end
      end
    end

    local function znix_try_fold_rust(bufnr, win)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
      if vim.b[bufnr].znix_tests_folded then return end
      if vim.bo[bufnr].filetype ~= "rust" then return end

      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.b[bufnr].znix_tests_folded then return end
        local wins = win and { win } or vim.fn.win_findbuf(bufnr)
        if #wins > 0 then
          znix_fold_rust_tests(bufnr, win)
          vim.b[bufnr].znix_tests_folded = true
        end
      end)
    end

    local rust_fold_group = vim.api.nvim_create_augroup("ZnixRustFoldTests", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = rust_fold_group,
      pattern = "rust",
      callback = function(args)
        znix_try_fold_rust(args.buf)
      end,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = rust_fold_group,
      callback = function(args)
        znix_try_fold_rust(args.buf, vim.api.nvim_get_current_win())
      end,
    })

    vim.api.nvim_create_user_command("RustFoldTests", function()
      _G.znix_toggle_rust_tests()
    end, { desc = "Свернуть / развернуть тесты в текущем Rust буфере" })

    -- Запоминание и автоматическое восстановление раскладки клавиатуры между Insert и Normal в Hyprland
    local function get_hyprland_layout()
      local out = vim.fn.system("hyprctl devices -j")
      if vim.v.shell_error ~= 0 then return 0 end
      local ok, data = pcall(vim.json.decode, out)
      if not ok or not data or type(data.keyboards) ~= "table" then return 0 end
      for _, kb in ipairs(data.keyboards) do
        if kb.main then
          return kb.active_layout_index or 0
        end
      end
      for _, kb in ipairs(data.keyboards) do
        if kb.layout and kb.layout:find(",") then
          return kb.active_layout_index or 0
        end
      end
      return 0
    end

    local znix_auto_layout_group = vim.api.nvim_create_augroup("ZnixAutoLayout", { clear = true })
    local znix_last_insert_layout = nil

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = znix_auto_layout_group,
      callback = function(args)
        if not (vim.env.HYPRLAND_INSTANCE_SIGNATURE and vim.fn.executable("hyprctl") == 1) then
          return
        end
        local current_layout = get_hyprland_layout()
        local bufnr = (args and args.buf) or vim.api.nvim_get_current_buf()
        vim.b[bufnr].znix_saved_layout = current_layout
        znix_last_insert_layout = current_layout
        if current_layout ~= 0 then
          vim.fn.jobstart({ "hyprctl", "switchxkblayout", "all", "0" }, { detach = true })
        end
      end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = znix_auto_layout_group,
      callback = function(args)
        if not (vim.env.HYPRLAND_INSTANCE_SIGNATURE and vim.fn.executable("hyprctl") == 1) then
          return
        end
        local bufnr = (args and args.buf) or vim.api.nvim_get_current_buf()
        local saved = vim.b[bufnr].znix_saved_layout or znix_last_insert_layout
        if saved and saved ~= 0 then
          vim.fn.jobstart({ "hyprctl", "switchxkblayout", "all", tostring(saved) }, { detach = true })
        end
      end,
    })
  '';
}

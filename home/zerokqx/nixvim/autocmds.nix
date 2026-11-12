{ ... }:
{
  extraConfigLua = ''
    -- Автосейв: Rust ждёт 2с между правками, остальные файлы — 500мс
    local autosave_timers = {}
    local function znix_cancel_save(buf)
      local timer = autosave_timers[buf]
      if timer then
        timer:stop()
        timer:close()
        autosave_timers[buf] = nil
      end
    end
    local function znix_can_save(buf)
      return vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].modified
        and vim.bo[buf].buftype == ""
        and vim.api.nvim_buf_get_name(buf) ~= ""
        and not vim.bo[buf].readonly
    end
    local function znix_debounced_save(buf)
      znix_cancel_save(buf)
      if not znix_can_save(buf) then return end
      local timer = vim.uv.new_timer()
      autosave_timers[buf] = timer
      timer:start(vim.bo[buf].filetype == "rust" and 2000 or 500, 0, vim.schedule_wrap(function()
        if autosave_timers[buf] ~= timer then return end
        znix_cancel_save(buf)
        if znix_can_save(buf) then
          local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
            vim.cmd("silent write")
          end)
          if not ok then
            vim.notify("Автосохранение: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
      end))
    end

    local autosave_group = vim.api.nvim_create_augroup("ZnixAutoSave", { clear = true })
    vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
      group = autosave_group,
      callback = function(args)
        znix_debounced_save(args.buf)
      end,
    })
    vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
      group = autosave_group,
      callback = function(args)
        znix_cancel_save(args.buf)
      end,
    })

    -- Автоматическое закрытие и удаление дашборда при открытии любого буфера
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "alpha", "starter", "ministarter" },
      callback = function(args)
        vim.bo[args.buf].bufhidden = "wipe"
      end,
    })

    -- Автоматическое включение inlay hints при подключении LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("ZnixLspAttach", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].filetype == "bigfile" then return end
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- Inlay hints (типы как в RustRover)
        if client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end,
    })

    -- Не обновляем миникарту и направляющие в буферах, распознанных Snacks BigFile.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("ZnixBigFile", { clear = true }),
      pattern = "bigfile",
      callback = function(args)
        vim.b[args.buf].minimap_disable = true
        vim.b[args.buf].snacks_indent = false
        vim.b[args.buf].snacks_scope = false
      end,
    })

    -- Сворачивание Rust-тестов без обхода каждого узла синтаксического дерева.
    local rust_query
    local rust_cache = {}
    local folded_windows = {}
    local test_attrs = {
      test = true,
      rstest = true,
      test_case = true,
      quickcheck = true,
      proptest = true,
    }

    local function rust_buffer(buf)
      return vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].filetype == "rust"
        and vim.bo[buf].buftype == ""
    end

    local function rust_test(node, buf)
      local name = node:field("name")[1]
      if node:type() == "mod_item" and name then
        local text = vim.treesitter.get_node_text(name, buf)
        if text == "test" or text == "tests" then return true end
      end

      local prev = node:prev_named_sibling()
      while prev do
        local kind = prev:type()
        if kind == "attribute_item" then
          local attribute = prev:named_child(0)
          local path = attribute and attribute:named_child(0)
          if path then
            local last = path:field("name")[1] or path
            local attr = vim.treesitter.get_node_text(last, buf)
            if test_attrs[attr] then return true end
            if path:type() == "identifier" and attr == "cfg"
              and vim.treesitter.get_node_text(prev, buf):match("^#%s*%[%s*cfg%s*%(%s*test%s*%)%s*%]$")
            then
              return true
            end
          end
        elseif kind ~= "line_comment" and kind ~= "block_comment" then
          break
        end
        prev = prev:prev_named_sibling()
      end
      return false
    end

    local function rust_test_lines(buf)
      local tick = vim.api.nvim_buf_get_changedtick(buf)
      local cached = rust_cache[buf]
      if cached and cached.tick == tick then return cached.lines, cached.top end

      local parser = vim.treesitter.get_parser(buf, "rust")
      local tree = parser and parser:parse()[1]
      if not tree then return {}, {} end
      rust_query = rust_query or vim.treesitter.query.parse("rust", "[(mod_item) (function_item)] @candidate")

      local tests, nodes = {}, {}
      for _, node in rust_query:iter_captures(tree:root(), buf, 0, -1) do
        if rust_test(node, buf) then
          tests[node:id()] = true
          nodes[#nodes + 1] = node
        end
      end

      local lines, top = {}, {}
      for _, node in ipairs(nodes) do
        local line = node:start() + 1
        lines[#lines + 1] = line
        local parent = node:parent()
        while parent and not tests[parent:id()] do
          parent = parent:parent()
        end
        if not parent then top[#top + 1] = line end
      end

      table.sort(lines, function(a, b) return a > b end)
      rust_cache[buf] = { tick = tick, lines = lines, top = top }
      return lines, top
    end

    local rust_fold_group = vim.api.nvim_create_augroup("ZnixRustFoldTests", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      group = rust_fold_group,
      callback = function(args)
        local win = vim.api.nvim_get_current_win()
        local buf = args.event == "WinEnter" and vim.api.nvim_win_get_buf(win) or args.buf
        if not rust_buffer(buf) then return end
        local folded = folded_windows[win] or {}
        folded_windows[win] = folded
        if folded[buf] ~= nil then return end
        -- Reserve this window/buffer pair before both events can queue it.
        folded[buf] = false

        vim.schedule(function()
          if folded[buf] ~= false then return end
          if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf
            or not rust_buffer(buf)
          then
            folded[buf] = nil
            return
          end

          local lines = rust_test_lines(buf)
          vim.api.nvim_win_call(win, function()
            for _, line in ipairs(lines) do
              vim.cmd("silent! " .. line .. "foldclose")
            end
          end)
          folded[buf] = true
        end)
      end,
    })
    vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
      group = rust_fold_group,
      callback = function(args)
        rust_cache[args.buf] = nil
        for _, folded in pairs(folded_windows) do folded[args.buf] = nil end
      end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
      group = rust_fold_group,
      callback = function(args)
        folded_windows[tonumber(args.match)] = nil
      end,
    })

    vim.api.nvim_create_user_command("RustFoldTests", function()
      local buf = vim.api.nvim_get_current_buf()
      if not rust_buffer(buf) then return end
      local lines, top = rust_test_lines(buf)
      if #lines == 0 then
        vim.notify("Тесты не найдены в файле", vim.log.levels.WARN, { title = "Rust Tests" })
        return
      end

      local open = false
      for _, line in ipairs(top) do
        if vim.fn.foldclosed(line) ~= -1 then
          open = true
          break
        end
      end
      local command = open and "foldopen!" or "foldclose"
      for _, line in ipairs(lines) do
        vim.cmd("silent! " .. line .. command)
      end
      vim.notify(open and "Тесты развёрнуты" or "Тесты свёрнуты", vim.log.levels.INFO, { title = "Rust Tests" })
    end, { desc = "Свернуть / развернуть тесты в текущем Rust буфере" })

    -- Последовательно обрабатываем раскладку, не блокируя редактор.
    local znix_last_insert_layout
    local layout_pending
    local layout_busy = false
    local update_layout

    local function finish_layout()
      layout_busy = false
      update_layout()
    end

    local function switch_layout(layout)
      vim.system({ "hyprctl", "switchxkblayout", "all", tostring(layout) }, {},
        vim.schedule_wrap(finish_layout))
    end

    update_layout = function()
      if layout_busy or not layout_pending then return end
      local request = layout_pending
      layout_pending = nil
      if not vim.api.nvim_buf_is_valid(request.buf) then return end
      layout_busy = true

      if request.insert then
        local saved = vim.b[request.buf].znix_saved_layout or znix_last_insert_layout
        if saved and saved ~= (request.current_layout or 0) then
          switch_layout(saved)
        else
          finish_layout()
        end
        return
      end

      vim.system({ "hyprctl", "devices", "-j" }, { text = true }, vim.schedule_wrap(function(result)
        local ok, data = pcall(vim.json.decode, result.stdout or "")
        if result.code ~= 0 or not ok or type(data) ~= "table" or type(data.keyboards) ~= "table" then
          finish_layout()
          return
        end
        local layout
        for _, kb in ipairs(data.keyboards) do
          if kb.main then
            layout = kb.active_layout_index or 0
            break
          elseif layout == nil and kb.layout and kb.layout:find(",") then
            layout = kb.active_layout_index or 0
          end
        end
        layout = layout or 0
        if vim.api.nvim_buf_is_valid(request.buf) then
          vim.b[request.buf].znix_saved_layout = layout
        end
        znix_last_insert_layout = layout
        -- Новое событие важнее: InsertEnter не должен получить позднее переключение на EN.
        if layout_pending then
          layout_pending.current_layout = layout
          finish_layout()
        elseif layout == 0 then
          finish_layout()
        else
          switch_layout(0)
        end
      end))
    end

    vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("ZnixAutoLayout", { clear = true }),
      callback = function(args)
        if not (vim.env.HYPRLAND_INSTANCE_SIGNATURE and vim.fn.executable("hyprctl") == 1) then
          return
        end
        layout_pending = { buf = args.buf, insert = args.event == "InsertEnter" }
        update_layout()
      end,
    })
  '';
}

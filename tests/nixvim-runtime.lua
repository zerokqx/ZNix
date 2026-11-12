-- Run with the built Home Manager editor in an isolated headless process.
local api = vim.api
assert(#api.nvim_list_uis() == 0, "Run this test with --headless")

local function check_layout()
  local calls = {}
  local system, executable = vim.system, vim.fn.executable
  vim.env.HYPRLAND_INSTANCE_SIGNATURE = "mock"
  vim.fn.executable = function(name)
    if name == "hyprctl" then return 1 end
    return executable(name)
  end
  vim.system = function(argv, opts, callback)
    if argv[1] ~= "hyprctl" then return system(argv, opts, callback) end
    calls[#calls + 1] = { argv = argv, callback = callback }
  end
  local from = api.nvim_create_buf(true, false)
  local to = api.nvim_create_buf(true, false)
  vim.b[to].znix_saved_layout = 0
  api.nvim_exec_autocmds("InsertLeave", { group = "ZnixAutoLayout", buffer = from })
  assert(calls[1] and calls[1].argv[2] == "devices", "layout query not queued")
  api.nvim_exec_autocmds("InsertEnter", { group = "ZnixAutoLayout", buffer = to })
  calls[1].callback({ code = 0, stdout = '{"keyboards":[{"main":true,"active_layout_index":1}]}' })
  assert(vim.wait(500, function() return #calls == 2 end, 5), "pending buffer never restored known EN layout")
  assert(calls[2].argv[2] == "switchxkblayout" and calls[2].argv[4] == "0", "pending buffer restored wrong layout")
  calls[2].callback({ code = 0 })
  vim.system, vim.fn.executable = system, executable
  vim.env.HYPRLAND_INSTANCE_SIGNATURE = nil
end

local function check_autosave()
  local timers = {}
  local new_timer = vim.uv.new_timer
  local function event(name, buf)
    vim.uv.new_timer = function()
      local timer = {
        start = function(self, delay, _, callback)
          self.delay = delay
          self.callback = callback
        end,
        stop = function() end,
        close = function(self) self.closed = true end,
      }
      timers[#timers + 1] = timer
      return timer
    end
    api.nvim_exec_autocmds(name, { group = "ZnixAutoSave", buffer = buf })
    vim.uv.new_timer = new_timer
  end
  local path = vim.fn.tempname()
  assert(vim.fn.writefile({ "old" }, path) == 0)
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  api.nvim_buf_set_lines(buf, 0, -1, false, { "new" })
  event("TextChanged", buf)
  event("TextChanged", buf)
  assert(#timers == 2 and timers[1].closed and timers[2].delay == 500, "save was not debounced")
  timers[1].callback()
  vim.wait(20, function() return false end, 5)
  assert(vim.fn.readfile(path)[1] == "old", "canceled callback wrote to disk")
  timers[2].callback()
  assert(vim.wait(500, function() return vim.fn.readfile(path)[1] == "new" end, 5), "scheduled write did not run")
  event("InsertLeave", buf)
  assert(#timers == 2, "unchanged buffer allocated a timer")
  api.nvim_buf_set_lines(buf, 0, -1, false, { "Rust" })
  vim.bo[buf].filetype = "rust"
  event("TextChanged", buf)
  assert(#timers == 3 and timers[3].delay == 2000, "Rust save delay changed")
  api.nvim_buf_delete(buf, { force = true, unload = true })
  assert(timers[3].closed, "unloading did not cancel the timer")
  timers[3].callback()
  vim.wait(20, function() return false end, 5)
  assert(vim.fn.readfile(path)[1] == "new", "unloaded buffer wrote to disk")
  vim.fn.delete(path)
end

local lines = {
  "#[cfg(test)]",
  "mod integration {",
  "  mod tests {",
  "    #[test]",
  "    fn nested() {",
  "      assert!(true);",
  "    }",
  "  }",
  "}",
  "",
  "#[tokio::test]",
  "async fn qualified() {",
  "  assert!(true);",
  "}",
  "",
  "#[contest]",
  "fn false_name() {",
  "  assert!(true);",
  "}",
  "",
  '#[ignore = "test"]',
  "fn false_string() {",
  "  assert!(true);",
  "}",
  "",
  '#[cfg(feature = "test")]',
  "mod false_cfg {",
  "  fn helper() {}",
  "}",
}

local path = vim.fn.tempname() .. ".rs"
assert(vim.fn.writefile(lines, path) == 0)
vim.lsp.enable("rust_analyzer", false)

local ok, err = xpcall(function()
  check_layout()
  check_autosave()
  vim.cmd.edit(vim.fn.fnameescape(path))
  local rust_buf = api.nvim_get_current_buf()
  local first_win = api.nvim_get_current_win()
  local function closed(line)
    return vim.fn.foldclosed(line) ~= -1
  end
  assert(vim.wait(1500, function() return closed(2) and closed(12) end, 10), "Rust tests did not auto-fold")
  assert(not closed(17) and not closed(22) and not closed(27), "unrelated attributes folded")

  vim.cmd.RustFoldTests()
  assert(not closed(2) and not closed(3) and not closed(5) and not closed(12), "nested tests did not unfold")
  vim.cmd.vsplit()
  local second_win = api.nvim_get_current_win()
  assert(second_win ~= first_win and api.nvim_get_current_buf() == rust_buf)
  assert(vim.wait(1500, function() return closed(2) and closed(12) end, 10), "second window did not fold tests")
  api.nvim_set_current_win(first_win)
  assert(not closed(2) and not closed(12), "returning to a window reset its fold choices")
  vim.cmd.RustFoldTests()
  assert(closed(2) and closed(12), "manual toggle did not close tests")

  -- An edit invalidates the discovery cache. The added test must become foldable.
  api.nvim_buf_set_lines(rust_buf, -1, -1, false, { "", "#[test]", "fn added() {", "  assert!(true);", "}" })
  assert(vim.wait(1500, function() return vim.fn.foldlevel(#lines + 3) > 0 end, 10), "new function fold was not computed")
  vim.cmd.RustFoldTests()
  vim.cmd.RustFoldTests()
  assert(closed(#lines + 3), "edited buffer reused stale Rust test lines")

  -- Before a queued fold callback executes, retarget the window to a plain buffer.
  vim.cmd.vnew()
  local retarget_win = api.nvim_get_current_win()
  local plain_buf = api.nvim_get_current_buf()
  api.nvim_buf_set_lines(plain_buf, 0, -1, false, lines)
  api.nvim_win_set_buf(retarget_win, rust_buf)
  api.nvim_win_set_buf(retarget_win, plain_buf)
  vim.wo[retarget_win].foldmethod = "manual"
  vim.cmd("2,9fold")
  vim.cmd("2foldopen")
  vim.wait(50, function() return false end, 5)
  assert(vim.fn.foldlevel(2) == 1 and not closed(2), "queued Rust callback folded the replacement buffer")
end, debug.traceback)
vim.fn.delete(path)
if not ok then
  api.nvim_err_writeln(err)
  vim.cmd.cquit()
end
print("Nixvim runtime checks passed: layout, autosave, Rust folds")
vim.cmd("qa!")

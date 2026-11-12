-- Run with the built Home Manager Nixvim package and -i NONE in an isolated
-- headless process. All files and Git operations below use a temporary fixture.
assert(#vim.api.nvim_list_uis() == 0, "Run this smoke test with --headless")

local function check()
  local root = vim.fn.tempname()
  vim.fn.mkdir(root, "p", 448)
  vim.cmd.cd(vim.fn.fnameescape(root))

  local function git(...)
    local argv = { "git", "-c", "core.hooksPath=/dev/null" }
    vim.list_extend(argv, { ... })
    local result = vim.system(argv, {
      cwd = root,
      text = true,
      env = { GIT_CONFIG_GLOBAL = "/dev/null", GIT_CONFIG_NOSYSTEM = "1" },
    }):wait()
    assert(result.code == 0, result.stderr)
  end

  for _, key in ipairs({ "ff", "e", "cf", "ct" }) do
    assert(vim.fn.maparg(vim.g.mapleader .. key, "n") ~= "", "Missing mapping: " .. key)
  end

  git("init", "--quiet")
  vim.fn.writefile({ "local value=1", "return value" }, "sample.lua")
  git("add", "--", "sample.lua")
  git("-c", "user.name=Nixvim Smoke", "-c", "user.email=smoke@example.invalid", "commit", "-qm", "fixture")
  vim.fn.writefile({ "local value=2", "return value" }, "sample.lua")
  vim.cmd.edit("sample.lua")
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.treesitter.highlighter.active[buf], "Lua Tree-sitter did not start")
  assert(vim.wait(5000, function()
    local status = vim.b[buf].gitsigns_status_dict
    return status and status.changed == 1
  end, 20), "Gitsigns did not detect the changed line")

  local format_done, format_error
  require("conform").format({ async = true, bufnr = buf }, function(err)
    format_error, format_done = err, true
  end)
  assert(vim.wait(5000, function() return format_done end, 20), "StyLua did not finish")
  assert(not format_error, tostring(format_error))
  assert(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "local value = 2",
    "Conform did not apply StyLua output")

  for _, source in ipairs({ "files", "explorer" }) do
    local picker = assert(Snacks.picker[source]({ cwd = root }), "Failed to open " .. source)
    assert(vim.wait(5000, function() return picker:current() ~= nil end, 20),
      "No fixture entries in Snacks " .. source)
    picker:close()
  end

  vim.cmd.enew({ bang = true })
  vim.snippet.expand("hello ${1:name}$0")
  assert(vim.api.nvim_get_current_line() == "hello name", "Native snippet expansion failed")
  vim.snippet.stop()

  local lines = vim.fn["repeat"]({ '  "' .. string.rep("a", 100) .. '",' }, 17000)
  table.insert(lines, 1, "[")
  table.insert(lines, "  null]")
  vim.fn.writefile(lines, "large.json")
  vim.cmd.edit({ args = { "large.json" }, bang = true })
  buf = vim.api.nvim_get_current_buf()
  assert(vim.bo[buf].filetype == "bigfile", "Snacks large-file detection did not fire")
  assert(not vim.treesitter.highlighter.active[buf], "Tree-sitter activated in large buffer")
  assert(vim.b[buf].minimap_disable and vim.b[buf].snacks_indent == false
    and vim.b[buf].snacks_scope == false, "Large-buffer decoration guards are missing")
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit")
    return
  end
  print("Nixvim smoke passed: mappings, Tree-sitter, Git, formatting, picker, explorer, snippets, large buffers")
  vim.cmd("qa!")
end)

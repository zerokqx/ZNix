-- Run with the built Home Manager Nixvim wrapper and isolated XDG state.
assert(#vim.api.nvim_list_uis() == 0, "Run this smoke test with --headless")

local function attach(filename, names)
  vim.cmd.edit(filename)
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.wait(12000, function()
    for _, name in ipairs(names) do
      if not vim.lsp.get_clients({ bufnr = buf, name = name })[1] then
        return false
      end
    end
    return true
  end, 30), "LSP attachment failed for " .. filename .. " (" .. table.concat(names, ", ") .. ")")
  return buf
end

local function check()
  local root = vim.fn.tempname()
  vim.fn.mkdir(root, "p", 448)
  vim.cmd.cd(vim.fn.fnameescape(root))
  local git = vim.system({ "git", "init", "--quiet", "--template=" }, {
    cwd = root,
    text = true,
    env = { GIT_CONFIG_GLOBAL = "/dev/null", GIT_CONFIG_NOSYSTEM = "1" },
  }):wait()
  assert(git.code == 0, git.stderr)

  vim.fn.writefile({ '{"name":"nixvim-lsp-smoke","private":true}' }, "package.json")
  vim.fn.writefile({ '{"compilerOptions":{"strict":true},"include":["**/*"]}' }, "tsconfig.json")
  vim.fn.writefile({ "[tool.ruff.lint]", 'select = ["F"]' }, "pyproject.toml")
  vim.fn.writefile({ "a {", "  col", "}" }, "sample.css")
  vim.fn.writefile({ "import sys", "", "x = 1" }, "sample.py")
  vim.fn.writefile({
    '<script setup lang="ts">',
    "const count = 1",
    "</script>",
    "<template>{{ count }}</template>",
  }, "App.vue")

  local css = attach("sample.css", { "cssls" })
  local cssls = vim.lsp.get_clients({ bufnr = css, name = "cssls" })[1]
  assert(cssls:supports_method("textDocument/completion", css), "CSSLS does not advertise completion")
  vim.api.nvim_win_set_cursor(0, { 2, 5 })
  local params = vim.lsp.util.make_position_params(0, cssls.offset_encoding)
  local response = cssls:request_sync("textDocument/completion", params, 3000, css)
  assert(response and type(response.result) == "table", "No CSS completion response")
  local items = response.result.items or response.result
  assert(vim.iter(items):any(function(item) return item.label == "color" end), "CSS completion misses color")
  assert(cssls.capabilities.textDocument.completion.completionItem.snippetSupport, "CSSLS lost snippet support")
  assert(vim.lsp.config.pyright.capabilities.textDocument.completion.completionItem.snippetSupport == false,
    "CSSLS snippet support leaked into other clients")

  local python = attach("sample.py", { "pyright", "ruff" })
  local ruff = vim.lsp.get_clients({ bufnr = python, name = "ruff" })[1]
  assert(not ruff:supports_method("textDocument/hover", python), "Ruff hover should be disabled")
  assert(vim.wait(7000, function()
    return vim.iter(vim.diagnostic.get(python)):any(function(diag) return diag.source == "Ruff" end)
  end, 50), "Ruff did not report the unused import")

  local vue = attach("App.vue", { "vue_ls", "vtsls" })
  local vtsls = vim.lsp.get_clients({ bufnr = vue, name = "vtsls" })[1].config.settings.vtsls
  local plugins = vim.tbl_get(vtsls, "tsserver", "globalPlugins") or {}
  assert(vim.iter(plugins):any(function(plugin)
    return plugin.name == "@vue/typescript-plugin" and vim.uv.fs_stat(plugin.location) ~= nil
  end), "Vue TypeScript plugin is missing or its package location is invalid")
  assert(vtsls.autoUseWorkspaceTsdk, "Vue integration lost the workspace TypeScript preference")
  assert(#vim.lsp.get_clients({ bufnr = vue, name = "ts_ls" }) == 0, "Redundant TypeScript client on Vue")

  local json = vim.lsp.config.jsonls.settings.json
  local yaml = vim.lsp.config.yamlls.settings.yaml
  assert(json.validate.enable and #json.schemas > 0 and not json.json, "Incorrect JSON schema configuration")
  assert(not yaml.schemaStore.enable and next(yaml.schemas) and not yaml.yaml, "Incorrect YAML schema configuration")
  assert(vim.lsp.config.lua_ls.settings.Lua.hint.enable, "Lua LS hint settings lost")
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln(err)
    vim.cmd("cquit")
    return
  end
  print("Nixvim LSP smoke passed: CSS completion, Ruff diagnostics, Vue TypeScript, JSON/YAML schemas, Lua hints")
  vim.cmd("qa!")
end)

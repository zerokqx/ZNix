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
  '';
}


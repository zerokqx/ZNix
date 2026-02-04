{ lib, config, ... }:
{
  plugins.conform-nvim = {
    enable = true;
    settings = {

      filter = ''
        function(bufnr)
          local ft = vim.bo[bufnr].filetype
          return ft ~= "markdown"
        end
      '';
      format_on_save = lib.nixvim.mkRaw ''
        function(bufnr)
          local path = vim.api.nvim_buf_get_name(bufnr)
          local ok, stats = pcall(vim.uv.fs_stat, path)
          if ok and stats and stats.size and stats.size > 256 * 1024 then
            return false
          end

          if vim.api.nvim_buf_get_option(bufnr, "buftype") ~= "" then
            return false
          end

          return {
            lsp_fallback = true,
            timeout_ms = 2000,
          }
        end
      '';
      formatters_by_ft = { };
      formatters = { };
    };
  };

  keymaps = lib.mkIf config.plugins.conform-nvim.enable [
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
      options = {
        silent = true;
        desc = "Format (Conform)";
      };
    }
  ];
}

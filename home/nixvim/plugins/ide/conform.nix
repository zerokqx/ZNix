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

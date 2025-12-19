{ lib, config, ... }:
{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      format_on_save = {
        lsp_fallback = true;
        timeout_ms = 5000;
      };
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

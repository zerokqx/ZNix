{ pkgs, lib, ... }:
{
  plugins.conform-nvim = {
    enable = false;
    settings = {
      default_format_opts.lsp_format = "fallback";
      formatters_by_ft = {
        bash = [ "shfmt" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        json = [ "prettier" ];
      };
      format_on_save = {
        lsp_fallback = true;
        timeout_ms = 200;
      };
      formaters = {

        prettier = {
          command = lib.getExe pkgs.nodePackages.prettier;
        };
      };
    };
  };
}

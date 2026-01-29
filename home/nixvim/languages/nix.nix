{
  pkgs,
  lib,
  ...
}:
{
  plugins = {
    nix.enable = true;
    hmts.enable = true;
    conform-nvim.settings = {
      formatters_by_ft = {
        nix = [ "nixfmt" ];
      };

      formatters = {
        nixfmt.command = lib.getExe pkgs.nixfmt-rfc-style;
      };
    };

    lint = {
      lintersByFt = {
        nix = [ "statix" ];
      };

      linters = {
        statix.cmd = lib.getExe pkgs.statix;
      };
    };

    lsp.servers.nixd = {
      enable = true;
      settings = {
        formatting = {
          command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
        };
      };
    };
  };
}

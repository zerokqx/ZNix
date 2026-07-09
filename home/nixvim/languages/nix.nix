{
  pkgs,
  lib,
  ...
}:
{
  plugins = {
    nix.enable = true;
    hmts.enable = false;
    conform-nvim.settings = {
      formatters_by_ft = {
        nix = [ "nixfmt" ];
      };
      formatters = {
        nixfmt.command = lib.getExe pkgs.nixfmt;
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
      filetypes = [ "nix" ];
      settings = {
        formatting = {
          command = [ "${lib.getExe pkgs.nixfmt}" ];
        };
      };
    };
  };
}

{ pkgs, lib, ... }:
{
  plugins = {
    conform-nvim.settings = {
      formatters_by_ft = {
        json = [ "jq" ];
      };

      formatters = {
        jq = {
          command = lib.getExe pkgs.jq;
        };
      };
    };

    # Включаем JSON-сервер
    lsp.servers.jsonls = {
      enable = true;
      filetypes = [
        "json"
        "jsonc"
      ];
    };

    schemastore = {
      enable = true;
      json = {
        enable = true;
      };
    };
  };
}

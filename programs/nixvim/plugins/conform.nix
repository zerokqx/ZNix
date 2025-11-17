{ pkgs, lib, ... }:
{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      format_on_save = {
        lspFallback = true;
        timeoutMs = 2000;
      };

      # Привязка форматтеров к типам файлов
      formatters_by_ft = {
        "_" = [
          "squeeze_blanks"
          "trim_whitespace"
          "trim_newlines"
        ];

        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        json = [ "jq" ];
        yaml = [ "yamlfmt" ];
      };

      # Определение самих форматтеров
      formatters = {
        _ = {
          command = "${pkgs.gawk}/bin/gawk";
        };

        squeeze_blanks = {
          command = lib.getExe' pkgs.coreutils "cat";
        };

        nixfmt = {
          command = lib.getExe pkgs.nixfmt-rfc-style;
        };

        stylua = {
          command = lib.getExe pkgs.stylua;
        };

        jq = {
          command = lib.getExe pkgs.jq;
          args = [ "." ]; # форматирует JSON
        };

        yamlfmt = {
          command = lib.getExe pkgs.yamlfmt;
        };
      };
    };
  };

  keymaps = [
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<cr>";
      options = {
        silent = true;
        desc = "Format";
      };
    }
  ];
}

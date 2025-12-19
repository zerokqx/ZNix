{ pkgs, lib, ... }:
{
  plugins = {
    conform-nvim.settings = {
      formatters_by_ft.css = {
        __unkeyed-1 = "prettierd";
        __unkeyed-2 = "prettier";
        timeout_ms = 2000;
        stop_after_first = true;
      };

      formatters = {
        prettierd.command = lib.getExe pkgs.prettierd;
        prettier.command = lib.getExe pkgs.nodePackages.prettier;
      };
    };

    lsp.servers = {
      cssls = {
        enable = true;
        cmd = [
          "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server"
          "--stdio"
        ];
      };

      tailwindcss = {
        enable = true;

        # только то, где реально есть классы tailwind
        filetypes = [
          "html"
          "css"
          "scss"
          "typescriptreact"
          "javascriptreact"
        ];

        # опционально: не автозапускать, а включать руками

        rootMarkers = [
          "tailwind.config.js"
          "tailwind.config.cjs"
          "tailwind.config.mjs"
          "tailwind.config.ts"
          "postcss.config.js"
          "package.json"
          ".git"
        ];
        cmd = [
          (lib.getExe pkgs.tailwindcss-language-server)
          "--stdio"
        ];
      };
    };
  };
}

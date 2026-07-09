{ pkgs, lib, ... }:
{
  plugins = {
    conform-nvim.settings = {
      formatters_by_ft = {
        css = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        scss = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          timeout_ms = 2000;
          stop_after_first = true;
        };
      };

      formatters = {
        prettierd.command = lib.getExe pkgs.prettierd;
        prettier.command = lib.getExe pkgs.prettier;
      };
    };

    lsp.servers = {
      cssls = {
        enable = true;
        filetypes = [
          "css"
          "scss"
          "less"
        ];
        cmd = [
          "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server"
          "--stdio"
        ];
      };

      somesass_ls = {
        enable = true;
        filetypes = [
          "sass"
          "scss"
        ];
        package = null;
        settings = {
          somesass = {
            workspace = {
              importAliases = {
                "@" = "./apps/frontend/src";
              };
            };
          };
        };
      };

      cssmodules_ls = {
        enable = true;
        filetypes = [
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
        ];
        package = null;
      };

      css_variables = {
        enable = true;
        filetypes = [
          "css"
          "scss"
          "sass"
          "less"
          "postcss"
          "html"
        ];
        package = pkgs.css-variables-language-server;
        settings = {
          cssVariables = {
            lookupFiles = [
              "**/*.css"
              "**/*.scss"
              "node_modules/@mantine/core/styles.css"
            ];
            blacklistFolders = [
              "**/.git"
              "**/.svn"
              "**/.hg"
              "**/CVS"
              "**/.DS_Store"
              "**/node_modules/!(@mantine)"
              "**/node_modules/@mantine/!(core)"
              "**/bower_components"
              "**/tmp"
              "**/dist"
              "**/tests"
            ];
          };
        };
      };

      tailwindcss = {
        enable = true;
        filetypes = [
          "html"
          "vue"
          "css"
          "scss"
          "typescriptreact"
          "javascriptreact"
        ];

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

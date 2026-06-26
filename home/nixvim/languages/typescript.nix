{ pkgs, lib, ... }:
{
  plugins = {

    conform-nvim = {
      settings = {
        formatters.prettier = {
          command = lib.getExe pkgs.prettier;
        };
        formatters_by_ft = {
          javascript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescript = [ "prettier" ];
          typescriptreact = [ "prettier" ];
        };
      };
    };

    lsp.servers.vtsls = {
      enable = true;
      filetypes = [
        "javascript"
        "javascriptreact"
        "typescript"
        "typescriptreact"
        "vue"
      ];
      extraOptions = {
        settings = {

          complete_function_calls = false;
          javascript = {
            inlayHints = {
              parameterNames = {
                enabled = "all";
                suppressWhenArgumentMatchesName = true;
              };
              parameterTypes.enabled = true;
              variableTypes.enabled = true;
              propertyDeclarationTypes.enabled = true;
              functionLikeReturnTypes.enabled = true;
              enumMemberValues.enabled = true;
            };
          };
          typescript = {
            exclude = [ "**/node_modules/**" ];
            inlayHints = {
              parameterNames = {
                enabled = "all";
                suppressWhenArgumentMatchesName = true;
              };
              parameterTypes.enabled = true;
              variableTypes.enabled = true;
              propertyDeclarationTypes.enabled = true;
              functionLikeReturnTypes.enabled = true;
              enumMemberValues.enabled = true;
            };
          };
        };
      };
    };

    lsp.servers.eslint = {
      enable = true;
      filetypes = [
        "javascript"
        "javascriptreact"
        "javascript.jsx"
        "typescript"
        "typescriptreact"
        "typescript.tsx"
        "html"
        "markdown"
        "json"
        "jsonc"
        "yaml"
        "toml"
        "xml"
        "gql"
        "graphql"
        "svelte"
        "css"
        "less"
        "scss"
        "pcss"
        "postcss"
      ];
    };

    ts-autotag = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.ft = [
          "javascript"
          "vue"
          "javascriptreact"
          "typescript"
          "typescriptreact"
          "html"
        ];

      };
      settings = {
        opts = {
          enable_close = true;
          enable_close_on_slash = true;
          enable_rename = true;
        };

        per_filetype = {
          html = {
            enable_close = true;
          };
        };
      };
    };
  };

}

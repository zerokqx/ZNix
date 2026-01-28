{ pkgs, lib, ... }:
{
  plugins = {

    conform-nvim = {
      settings = {

        formatters.prettier = {
          command = lib.getExe pkgs.nodePackages.prettier;
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
      ];

      extraOptions = {
        settings = {

          complete_function_calls = false;
          javascript = {
            inlayHints = {
              includeInlayEnumMemberValueHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayVariableTypeHints = true;
            };
          };
          typescript = {
            exclude = [ "**/node_modules/**" ];
            inlayHints = {
              includeInlayEnumMemberValueHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayVariableTypeHints = true;
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
        "vue"
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
          "javascriptreact"
          "typescript"
          "typescriptreact"
        ];

      };
      settings = {
        opts = {
          enable_close = true;
          enable_close_on_slash = false;
          enable_rename = true;
        };
        per_filetype = {
          html = {
            enable_close = false;
          };
        };
      };
    };
  };

}

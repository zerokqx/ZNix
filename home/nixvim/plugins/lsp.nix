{ pkgs, ... }:

{
  plugins = {
    lspkind.enable = true;
    lsp-lines = {
      enable = false;
    };
    lsp-format = {
      enable = false;
    };
    lsp-signature.enable = true;
    lsp = {
      enable = true;
      inlayHints = false;
      servers = {
        prismals = {
          enable = true;
          package = pkgs.prisma-language-server;
        };
        html = {
          enable = true;
        };
        nil_ls = {
          enable = true;
        };
        jsonls = {
          enable = true;
        };
        cssls = {
          enable = true;
        };
        yamlls = {
          enable = true;
          extraOptions = {
            settings = {
              yaml = {
                schemas = {
                  kubernetes = "'*.yaml";
                  "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
                  "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
                  "http://json.schemastore.org/ansible-stable-2.9" = "roles/tasks/*.{yml,yaml}";
                  "http://json.schemastore.org/kustomization" = "kustomization.{yml,yaml}";
                  "http://json.schemastore.org/ansible-playbook" = "*play*.{yml,yaml}";
                  "http://json.schemastore.org/chart" = "Chart.{yml,yaml}";
                  "https://json.schemastore.org/dependabot-v2" = ".github/dependabot.{yml,yaml}";
                  "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" =
                    "*docker-compose*.{yml,yaml}";
                  "https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json" =
                    "*flow*.{yml,yaml}";
                };
              };
            };
          };
        };
      };

      keymaps = {
        silent = true;
        #     extra = [
        #     ];
        lspBuf = {
          #       "K" = {
          #         action = "hover";
          #         desc = "LSP hover";
          #       };
          #
          #       "gd" = {
          #         action = "definition";
          #         desc = "LSP definition"; };
          #       "gD" = {
          #         action = "declaration";
          #         desc = "LSP declaration";
          #       };
          #
          #       "gi" = {
          #         action = "implementation";
          #         desc = "LSP implementation";
          #       };
          #
          #       "gr" = {
          #         action = "references";
          #         desc = "LSP references";
          #       };
          #
          "<leader>ca" = {
            action = "code_action";
            desc = "LSP code action";
          };
          #
          "<leader>rn" = {
            action = "rename";
            desc = "LSP rename";
          };
        };
      };
    };

    # trouble = {
    #   enable = ;
    # };
  };

  extraconfiglua = ''
    local _border = "rounded"

    vim.lsp.handlers["textdocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, { border = _border }
    )
    vim.lsp.handlers["textdocument/signaturehelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, { border = _border }
    )
    vim.diagnostic.config {
      float = { border = _border },
      underline = true,
      virtual_text = { spacing = 5, severity_limit = "warning" },
      update_in_insert = false,
    }

    require("lspconfig.ui.windows").default_options = {
      border = _border,
    }

    vim.lsp.handlers["textdocument/publishdiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics,
      {
        underline = true,
        virtual_text = {
          spacing = 5,
          severity_limit = "warning",
        },
        update_in_insert = true,
      }
    )
  '';
}

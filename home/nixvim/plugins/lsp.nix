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
    helm = {
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
        qmlls.enable = true;
        html = {

          enable = true;
        };
        lua_ls = {
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

      # Ключевые биндинги с интеграцией Snacks
      keymaps = {
        silent = true;
        extra = [
          # {
          #   mode = "n";
          #   key = "gr";
          #   action = "<cmd> lua Snacks.picker.lsp_references()<cr>";
          #   options = {
          #     unique = true;
          #     nowait = true;
          #     desc = "Snacks: LSP References";
          #   };
          # }
          # {
          #   mode = "n";
          #   key = "gii";
          #   action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
          #   options = {
          #     unique = true;
          #     nowait = true;
          #     desc = "Snacks: LSP Implementations";
          #   };
          # }
        ];
        lspBuf = {
          # "gi" = "implementation";
          #   gd = {
          #     action = "definition";
          #     desc = "LSP: Go to Definition";
          #   };
          #   gD = {
          #     action = "declaration";
          #     desc = "LSP: Go to Declaration";
          #   };
          #   gt = {
          #     action = "type_definition";
          #     desc = "LSP: Type Definition";
          #   };
          #   K = {
          #     action = "hover";
          #     desc = "LSP: Hover";
          #   };
          #   "<leader>ca" = {
          #     action = "code_action";
          #     desc = "LSP: Code Action";
          #   };
          #   "<leader>cf" = {
          #     action = "format";
          #     desc = "LSP: Format";
          #   };
          #   "<leader>cw" = {
          #     action = "workspace_symbol";
          #     desc = "LSP: Workspace Symbol";
          #   };
          #   "<leader>cr" = {
          #     action = "rename";
          #     desc = "LSP: Rename";
          #   };
        };
      };
    };

    trouble = {
      enable = true;
    };
  };

  extraConfigLua = ''
    local _border = "rounded"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, { border = _border }
    )
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, { border = _border }
    )
    vim.diagnostic.config {
      float = { border = _border },
      underline = true,
      virtual_text = { spacing = 5, severity_limit = "Warning" },
      update_in_insert = false,
    }

    require("lspconfig.ui.windows").default_options = {
      border = _border,
    }

    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics,
      {
        underline = true,
        virtual_text = {
          spacing = 5,
          severity_limit = "Warning",
        },
        update_in_insert = true,
      }
    )
  '';
}

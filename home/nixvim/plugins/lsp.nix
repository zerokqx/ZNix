{ pkgs, ... }:

{
  plugins = {
    lspkind.enable = true;
    lsp-signature.enable = true;
    lsp = {
      enable = true;
      inlayHints = false;
      servers = {
        prismals = {
          enable = true;
          package = pkgs.prisma-language-server;
        };
        jsonls = {
          enable = true;
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

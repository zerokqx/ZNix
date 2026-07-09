{ pkgs, ... }:

{
  plugins = {
    lspkind.enable = true;
    lsp-signature.enable = false;
    lsp = {
      enable = true;
      inlayHints = false;
      servers = {
        prismals = {
          enable = true;
          package = pkgs.prisma-language-server;
          filetypes = [ "prisma" ];
        };
        jsonls = {
          enable = true;
          filetypes = [
            "json"
            "jsonc"
          ];
        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          "<leader>ca" = {
            action = "code_action";
            desc = "LSP code action";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "LSP rename";
          };
        };
      };
    };
  };

  extraConfigLua = ''
    local _border = "rounded"

    vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
      return vim.lsp.handlers.hover(
        err,
        result,
        ctx,
        vim.tbl_deep_extend("force", { border = _border, winblend = 0 }, config or {})
      )
    end
    vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
      return vim.lsp.handlers.signature_help(
        err,
        result,
        ctx,
        vim.tbl_deep_extend("force", { border = _border, winblend = 0 }, config or {})
      )
    end
    pcall(function()
      require("lspconfig.ui.windows").default_options = {
        border = _border,
      }
    end)

    local function nixvim_on_attach(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf
      if not client then return end

      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      local is_large = ok and stats and stats.size and stats.size > 256 * 1024

      local disable_format = {
        tsserver = true,
        vtsls = true,
        eslint = true,
      }

      if disable_format[client.name] or is_large then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      if client.name == "vtsls" then
        client.server_capabilities.documentHighlightProvider = false
      end

      if is_large and client.server_capabilities.semanticTokensProvider then
        client.server_capabilities.semanticTokensProvider = nil
      end

      if vim.lsp.inlay_hint and type(vim.lsp.inlay_hint.enable) == "function" then
        local ok_new = pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
        if not ok_new then
          pcall(vim.lsp.inlay_hint.enable, bufnr, false)
        end
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = nixvim_on_attach,
    })
  '';
}

{ inputs, ... }:
{
  programs.nixvim = {
    enable = true;

    imports = [
      ./autocmds.nix
      ./languages
      ./plugins
      ./keymaps.nix
      ./opts.nix
    ];

    extraConfigLua = ''
      vim.fn.sign_define("DiagnosticSignError",{text="",numhl=""})
      vim.fn.sign_define("DiagnosticSignWarn",{text="",numhl=""})
      vim.fn.sign_define("DiagnosticSignInfo",{text="",numhl=""})
      vim.fn.sign_define("DiagnosticSignHint",{text="",numhl=""})
      vim.api.nvim_set_hl(0,"DiagnosticVirtualTextError",{fg="#E53935",bg="#201212"})
      vim.api.nvim_set_hl(0,"DiagnosticVirtualTextWarn",{fg="#FFD54F",bg="#2A2416"})
      vim.api.nvim_set_hl(0,"DiagnosticVirtualTextInfo",{fg="#81D4FA",bg="#15222B"})
      vim.api.nvim_set_hl(0,"DiagnosticVirtualTextHint",{fg="#C5E1A5",bg="#1E2B1A"})

      vim.diagnostic.config({
        signs=false,
        virtual_text = {
          prefix = function(d)
            return ({
              [vim.diagnostic.severity.ERROR] = "",
              [vim.diagnostic.severity.WARN]  = "",
              [vim.diagnostic.severity.INFO]  = "",
              [vim.diagnostic.severity.HINT]  = "",
            })[d.severity]
          end,
          spacing = 2,
        },
        severity_sort = true,
      })

      -- Float diagnostics (цветной текст, без фона) + иконки
      vim.api.nvim_set_hl(0,"DiagnosticFloatingError",{fg="#E53935"})
      vim.api.nvim_set_hl(0,"DiagnosticFloatingWarn",{fg="#FFD54F"})
      vim.api.nvim_set_hl(0,"DiagnosticFloatingInfo",{fg="#81D4FA"})
      vim.api.nvim_set_hl(0,"DiagnosticFloatingHint",{fg="#C5E1A5"})

      local function diag_float_cursor()
        vim.diagnostic.open_float(nil, {
          scope = "cursor",
          border = "rounded",
          source = "if_many",
          focusable = false,
          prefix = function(d)
            return ({
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN]  = " ",
              [vim.diagnostic.severity.INFO]  = " ",
              [vim.diagnostic.severity.HINT]  = "󰌵 ",
            })[d.severity]
          end,
        })
      end

      -- Команда для вызова из Cmd:
      -- :CustomDiagnosticCommand
      vim.api.nvim_create_user_command("CustomDiagnosticCommand", diag_float_cursor, {})

    '';
  };
}

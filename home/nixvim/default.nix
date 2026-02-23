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
      vim.diagnostic.config({
        virtual_text = {
          prefix = "■",
          spacing = 2,
          source = "if_many",
        },
        signs = false,
        underline = true,
        severity_sort = true,
        update_in_insert = false,

        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          focusable = true,
          scope = "cursor",
        },
      })


            local function diag_float_cursor()
              vim.diagnostic.open_float(nil, {
                scope = "line",
                border = "rounded",
                source = "if_many",
                focusable = true,
              })
            end
            vim.api.nvim_create_user_command("CustomDiagnosticCommand", diag_float_cursor, {})

    '';
  };
}

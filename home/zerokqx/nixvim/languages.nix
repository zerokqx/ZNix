{ pkgs, lib, ... }:
{

  plugins.schemastore = {
    enable = true;
    json.enable = true;
    yaml.enable = true;
  };

  plugins.lsp = {
    enable = true;
    servers = {

      nixd = {
        enable = true;
        settings = {
          formatting.command = [ "nixfmt" ];
          nixpkgs.expr = "import <nixpkgs> { }";
        };
      };

      taplo = {
        enable = true;
      };

      yamlls = {
        enable = true;
        settings = {
          yaml = {
            schemaStore = {
              enable = false;
              url = "";
            };
          };
        };
      };

      jsonls = {
        enable = true;
        settings = {
          json = {
            validate.enable = true;
          };
        };
      };

      marksman = {
        enable = true;
      };

      dockerls.enable = true;
      docker_compose_language_service.enable = true;

      bashls.enable = true;

      nginx_language_server.enable = true;

      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        settings = {
          checkOnSave = true;
          check = {
            command = "clippy";
          };
          procMacro = {
            enable = true;
          };
        };
      };

      ts_ls = {
        enable = true;
        autostart = true;
      };

      lua_ls = {
        enable = true;
        extraOptions = {
          settings = {
            Lua = {
              diagnostics = {
                globals = [ "vim" ];
              };
              telemetry = {
                enabled = false;
              };
            };
          };
        };
      };

      html.enable = true;
      cssls.enable = true;
    };
  };

  plugins.conform-nvim = {
    enable = true;
    settings.formatters_by_ft = lib.mkForce {

      nix = [ "nixfmt" ];

      rust = [ "rustfmt" ];

      javascript = [
        "prettierd"
        "prettier"
      ];
      javascriptreact = [
        "prettierd"
        "prettier"
      ];
      typescript = [
        "prettierd"
        "prettier"
      ];
      typescriptreact = [
        "prettierd"
        "prettier"
      ];
      html = [
        "prettierd"
        "prettier"
      ];
      css = [
        "prettierd"
        "prettier"
      ];
      scss = [
        "prettierd"
        "prettier"
      ];
      less = [
        "prettierd"
        "prettier"
      ];
      graphql = [
        "prettierd"
        "prettier"
      ];

      json = [
        "prettierd"
        "prettier"
      ];
      jsonc = [
        "prettierd"
        "prettier"
      ];
      yaml = [
        "yamlfmt"
        "prettierd"
        "prettier"
      ];
      toml = [ "taplo" ];

      sh = [ "shfmt" ];
      bash = [ "shfmt" ];

      lua = [ "stylua" ];

      python = [
        "ruff_format"
        "black"
      ];

      markdown = [
        "prettierd"
        "prettier"
      ];
      "markdown.mdx" = [
        "prettierd"
        "prettier"
      ];
    };
  };

  extraPackages = with pkgs; [

    nixd
    nixfmt

    taplo
    yaml-language-server
    yamlfmt
    vscode-langservers-extracted
    marksman
    dockerfile-language-server
    docker-compose-language-service
    nginx-language-server
    bash-language-server
    shfmt
    shellcheck

    rust-analyzer
    rustfmt
    clippy
    cargo
    rustc

    typescript-language-server
    typescript
    nodejs
    prettierd
    prettier

    lua-language-server
    stylua

    ruff
    black

    ripgrep
    fd
    imagemagick
  ];
}

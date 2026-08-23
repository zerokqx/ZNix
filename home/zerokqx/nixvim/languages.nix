{ pkgs, lib, ... }:
{
  # Поддержка сотен JSON/YAML схем (package.json, tsconfig, GitHub actions, compose и др.)
  plugins.schemastore = {
    enable = true;
    json.enable = true;
    yaml.enable = true;
  };

  # Настройка LSP серверов
  plugins.lsp = {
    enable = true;
    servers = {
      # 1. Nix
      nixd = {
        enable = true;
        settings = {
          formatting.command = [ "nixfmt" ];
          nixpkgs.expr = "import <nixpkgs> { }";
        };
      };

      # 2. TOML (Cargo.toml, pyproject.toml, starship.toml и др.)
      taplo = {
        enable = true;
      };

      # 3. YAML (k8s, docker-compose, CI/CD, configs)
      yamlls = {
        enable = true;
        settings = {
          yaml = {
            schemaStore = {
              enable = false; # Используем schemastore.nvim
              url = "";
            };
          };
        };
      };

      # 4. JSON
      jsonls = {
        enable = true;
        settings = {
          json = {
            validate.enable = true;
          };
        };
      };

      # 5. Markdown
      marksman = {
        enable = true;
      };

      # 6. Docker & Docker Compose
      dockerls.enable = true;
      docker_compose_language_service.enable = true;

      # 7. Bash / Shell / .env / scripts
      bashls.enable = true;

      # 8. Nginx (конфигурационные файлы)
      nginx_language_server.enable = true;

      # 9. Языки программирования (Rust, TS/JS, Lua, HTML, CSS)
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

  # Форматтеры для всех поддерживаемых языков
  plugins.conform-nvim = {
    enable = true;
    settings.formatters_by_ft = lib.mkForce {
    # 1. Nix
    nix = [ "nixfmt" ];

    # 2. Rust
    rust = [ "rustfmt" ];

    # 3. Web & Frontend (TS, JS, JSX, TSX, HTML, CSS, SCSS, LESS, GraphQL)
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

    # 4. Конфигурационные файлы (JSON, JSONC, YAML, TOML)
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

    # 5. Shell & Скрипты
    sh = [ "shfmt" ];
    bash = [ "shfmt" ];

    # 6. Lua
    lua = [ "stylua" ];

    # 7. Python
    python = [
      "ruff_format"
      "black"
    ];

    # 8. Markdown
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

  # Добавление бинарников прямо в Neovim
  extraPackages = with pkgs; [
    # Nix
    nixd
    nixfmt

    # Конфигурационные языки (TOML, YAML, JSON, Markdown, Docker, Nginx, Shell)
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

    # Rust
    rust-analyzer
    rustfmt
    clippy
    cargo
    rustc

    # Web / TypeScript / Node
    typescript-language-server
    typescript
    nodejs
    prettierd
    prettier

    # Lua
    lua-language-server
    stylua

    # Python
    ruff
    black

    # Утилиты
    ripgrep
    fd
  ];
}

{ pkgs, lib, ... }:
let
  cssmodules-language-server = pkgs.buildNpmPackage {
    pname = "cssmodules-language-server";
    version = "1.5.2";
    src = pkgs.fetchFromGitHub {
      owner = "antonk52";
      repo = "cssmodules-language-server";
      rev = "v1.5.2";
      hash = "sha256-9RZNXdmBP4OK7k/0LuuvqxYGG2fESYTCFNCkAWZQapk=";
    };
    npmDepsHash = "sha256-1CnCgut0Knf97+YHVJGUZqnRId/BwHw+jH1YPIrDPCA=";
  };
in
{

  plugins.schemastore = {
    enable = true;
    json.enable = true;
    yaml.enable = true;
  };

  plugins.haskell-tools = {
    enable = true;
  };
  plugins.lsp = {
    enable = true;
    servers = {
      # hls.enable = true;
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

      ocamllsp.enable = true;

      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        settings = {
          checkOnSave = true;
          check = {
            command = "clippy";
            extraArgs = [
              "--target-dir"
              "target/analyzer"
            ];
          };
          cargo = {
            allFeatures = true;
            loadOutDirsFromCheck = true;
            buildScripts.enable = true;
          };
          completion = {
            autoimport.enable = true;
            autoself.enable = true;
            fullFunctionSignatures.enable = true;
            postfix.enable = true;
            callable.snippets = "fill_arguments";
          };
          hover = {
            actions = {
              enable = true;
              run.enable = true;
              debug.enable = true;
              references.enable = true;
              implementations.enable = true;
            };
          };
          imports = {
            granularity.group = "module";
            prefix = "self";
            merge.glob = false;
          };
          typing = {
            autoClosingAngleBrackets.enable = true;
          };
          workspace = {
            symbol.search = {
              scope = "workspace";
              kind = "all_symbols";
            };
          };
          semanticHighlighting = {
            operator.specialization.enable = true;
            punctuation = {
              enable = true;
              specialization.enable = true;
              separate.macro.bang = true;
            };
            strings.enable = true;
          };
          diagnostics = {
            enable = true;
            experimental.enable = true;
            styleLints.enable = true;
          };
          files = {
            excludeDirs = [
              ".git"
              ".direnv"
              "target"
            ];
          };
          procMacro = {
            enable = true;
          };
          inlayHints = {
            bindingModeHints.enable = false;
            chainingHints.enable = true;
            closingBraceHints.enable = true;
            closureReturnTypeHints.enable = "always";
            lifetimeElisionHints.enable = "never";
            parameterHints.enable = true;
            typeHints.enable = true;
            maxLength = 40;
            renderColons = true;
          };
        };
      };

      ts_ls = {
        enable = true;
        autostart = true;
        extraOptions = {
          settings = {
            javascript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true;
                includeInlayFunctionLikeReturnTypeHints = true;
                includeInlayFunctionParameterTypeHints = true;
                includeInlayParameterNameHints = "all";
                includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                includeInlayPropertyDeclarationTypeHints = true;
                includeInlayVariableTypeHints = true;
              };
            };
            typescript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true;
                includeInlayFunctionLikeReturnTypeHints = true;
                includeInlayFunctionParameterTypeHints = true;
                includeInlayParameterNameHints = "all";
                includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                includeInlayPropertyDeclarationTypeHints = true;
                includeInlayVariableTypeHints = true;
              };
            };
          };
        };
      };

      lua_ls = {
        enable = true;
        extraOptions = {
          settings = {
            Lua = {
              hint = {
                enable = true;
                setType = true;
                paramType = true;
                paramName = "All";
                semicolon = "Disable";
                arrayIndex = "Disable";
              };
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

      css_variables = {
        enable = true;
        package = pkgs.css-variables-language-server;
      };

      cssmodules_ls = {
        enable = true;
        package = cssmodules-language-server;
      };
    };
  };

  plugins.render-markdown = {
    enable = true;
    settings = {
      heading = {
        enabled = true;
        sign = false;
        position = "overlay";
        icons = [
          "󰲡 "
          "󰲣 "
          "󰲥 "
          "󰲧 "
          "󰲩 "
          "󰲫 "
        ];
      };
      code = {
        enabled = true;
        sign = false;
        style = "full";
        position = "left";
        language_pad = 0;
        border = "thin";
      };
      bullet = {
        enabled = true;
        icons = [
          "■"
          "□"
          "◆"
          "◇"
        ];
      };
      checkbox = {
        enabled = true;
        unchecked = {
          icon = "󰄱 ";
        };
        checked = {
          icon = "󰄲 ";
        };
      };
      pipe_table = {
        enabled = true;
        preset = "single";
        style = "full";
      };
      dash = {
        enabled = true;
        icon = "─";
      };
      callout = {
        note = {
          raw = "[!NOTE]";
          rendered = "󰋽 Note";
          highlight = "RenderMarkdownInfo";
        };
        tip = {
          raw = "[!TIP]";
          rendered = "󰌶 Tip";
          highlight = "RenderMarkdownSuccess";
        };
        important = {
          raw = "[!IMPORTANT]";
          rendered = "󰅾 Important";
          highlight = "RenderMarkdownHint";
        };
        warning = {
          raw = "[!WARNING]";
          rendered = "󰀪 Warning";
          highlight = "RenderMarkdownWarn";
        };
        caution = {
          raw = "[!CAUTION]";
          rendered = "󰳦 Caution";
          highlight = "RenderMarkdownError";
        };
      };
      win_options = {
        conceallevel = {
          default = 2;
          rendered = 2;
        };
      };
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

      ocaml = [ "ocamlformat" ];

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
    haskell-language-server
    hlint
    ormolu # форматировщик кода (по желанию)
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

    ocamlPackages.ocaml-lsp
    ocamlformat

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
    css-variables-language-server
    cssmodules-language-server

    lua-language-server
    stylua

    ruff
    black

    ripgrep
    fd
    imagemagick
  ];
}

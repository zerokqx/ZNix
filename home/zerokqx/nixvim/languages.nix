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

  prettierOrOxfmt = lib.nixvim.mkRaw ''
    function(bufnr)
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local ctx = { dirname = vim.fs.dirname(filename) }
      if require("conform.formatters.prettierd").cwd(nil, ctx) then
        return { "prettierd", "prettier", stop_after_first = true }
      end
      return { "oxfmt" }
    end
  '';
in
{

  plugins.schemastore = {
    enable = true;
    json.enable = true;
    yaml.enable = true;
  };

  plugins.lsp = {
    enable = true;
    servers = {
      sqls.enable = true;
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

      mdx_analyzer = {
        enable = true;
        package = pkgs.mdx-language-server;
        cmd = [
          "mdx-language-server"
          "--stdio"
        ];
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

      vtsls = {
        enable = true;
        autostart = true;
        extraOptions = {
          settings = {
            vtsls.autoUseWorkspaceTsdk = true;
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

      oxlint = {
        enable = true;
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

      pyright = {
        enable = true;
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true;
              useLibraryCodeForTypes = true;
              diagnosticMode = "openFilesOnly";
              inlayHints = {
                variableTypes = true;
                functionReturnTypes = true;
              };
            };
          };
        };
      };

      ruff = {
        enable = true;
        onAttach.function = ''
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        '';
      };

      vue_ls = {
        enable = true;
        tslsIntegration = false;
      };

      html = {
        enable = true;
        filetypes = [
          "html"
          "templ"
          "vue"
        ];
      };

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
    settings = {
      default_format_opts = {
        lsp_format = "fallback";
        timeout_ms = 5000;
        stop_after_first = true;
      };
      formatters = {
        oxfmt = {
          command = "oxfmt";
          args = [ "--stdin-filepath" "$FILENAME" ];
        };
        prettier = {
          timeout_ms = 5000;
        };
        prettierd = {
          timeout_ms = 5000;
        };
      };
      formatters_by_ft = lib.mkForce {

      nix = [ "nixfmt" ];

      rust = [ "rustfmt" ];

      javascript = prettierOrOxfmt;
      javascriptreact = prettierOrOxfmt;
      typescript = prettierOrOxfmt;
      typescriptreact = prettierOrOxfmt;
      vue = [
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

      sql = [
        "sqlfluff"
        "sql-formatter"
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
};

  extraPackages = with pkgs; [
    sqls
    sqlfluff
    sql-formatter

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

    vtsls
    vue-language-server
    typescript
    nodejs
    oxfmt
    prettierd
    prettier
    oxlint
    css-variables-language-server
    cssmodules-language-server

    lua-language-server
    stylua

    pyright
    ruff
    black

    ripgrep
    fd
    imagemagick
  ];
}

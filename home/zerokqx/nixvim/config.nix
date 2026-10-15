{ lib, ... }:
{
  imports = [
    ./mini.nix
    ./snacks.nix
    ./languages.nix
    ./completion.nix
    ./flash.nix
    ./keymaps.nix
    ./opts.nix
    ./autocmds.nix
  ];

  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night";
      transparent = false;
      terminal_colors = true;
      styles = {
        sidebars = "dark";
        floats = "dark";
      };
    };
  };

  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = false;
    };
  };
  plugins.ts-context-commentstring.enable = true;
  plugins.ts-autotag = {
    enable = true;
    settings = {
      opts = {
        enable_close = true;
        enable_close_on_slash = true;
        enable_rename = true;
      };
    };
  };

  plugins.which-key = {
    enable = true;
    settings = {
      preset = "modern";
      delay = 200;
      icons = {
        breadcrumb = "»";
        separator = "➜";
        group = "+";
        mappings = true;
        rules = [
          {
            pattern = "code";
            icon = " ";
            color = "cyan";
          }
          {
            pattern = "format";
            icon = "󰉢 ";
            color = "cyan";
          }
          {
            pattern = "rename";
            icon = "󰑕 ";
            color = "orange";
          }
          {
            pattern = "git";
            icon = "󰊢 ";
            color = "orange";
          }
          {
            pattern = "find";
            icon = " ";
            color = "green";
          }
          {
            pattern = "file";
            icon = "󰈔 ";
            color = "azure";
          }
          {
            pattern = "buffer";
            icon = "󰈚 ";
            color = "blue";
          }
          {
            pattern = "diagnostics";
            icon = "󰒡 ";
            color = "red";
          }
          {
            pattern = "terminal";
            icon = " ";
            color = "purple";
          }
          {
            pattern = "window";
            icon = " ";
            color = "yellow";
          }
          {
            pattern = "goto";
            icon = "󰌹 ";
            color = "magenta";
          }
        ];
      };
      spec = [
        {
          __unkeyed-1 = "<leader>c";
          group = "Code";
          icon = " ";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "Search";
          icon = " ";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "Git";
          icon = "󰊢 ";
        }
        {
          __unkeyed-1 = "<leader>h";
          group = "Hunk";
          icon = "󰊢 ";
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "Buffer";
          icon = "󰈚 ";
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "Window";
          icon = " ";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "Terminal";
          icon = " ";
        }
        {
          __unkeyed-1 = "gt";
          group = "Go To";
          icon = "󰌹 ";
        }
        {
          __unkeyed-1 = "z";
          group = "Folds (Сворачивание)";
          icon = " ";
        }
      ];
    };
  };

  plugins.gitsigns = {
    enable = true;
    settings = {
      signs = {
        add = {
          text = "▎";
        };
        change = {
          text = "▎";
        };
        delete = {
          text = "";
        };
        topdelete = {
          text = "";
        };
        changedelete = {
          text = "▎";
        };
        untracked = {
          text = "┆";
        };
      };
      signs_staged = {
        add = {
          text = "▎";
        };
        change = {
          text = "▎";
        };
        delete = {
          text = "";
        };
        topdelete = {
          text = "";
        };
        changedelete = {
          text = "▎";
        };
        untracked = {
          text = "┆";
        };
      };
      current_line_blame = false;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "eol";
        delay = 300;
      };
      signcolumn = true;
    };
  };

  plugins.fidget = {
    enable = true;
    settings = {
      notification = {
        override_vim_notify = false;
        window = {
          winblend = 0;
          border = "none";
        };
      };
      progress = {
        display = {
          done_icon = "✔ ";
          progress_icon = {
            pattern = "dots";
            period = 1;
          };
        };
      };
    };
  };

  globals.loaded_matchparen = 1;

  luaLoader.enable = true;
  performance = {
    byteCompileLua = {
      enable = true;
      configs = true;
      initLua = true;
      plugins = true;
    };
  };

  extraFiles = {
    "doc/cheatsheet.txt".text = builtins.readFile ../../../docs/cheatsheet.txt;
  };

  extraConfigLua = ''
    vim.o.winborder = "rounded"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = "rounded",
        max_width = 80,
        max_height = 25,
        focusable = true,
      }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = "rounded",
        max_width = 80,
        max_height = 20,
        focusable = false,
      }
    )

    vim.diagnostic.config({
      virtual_text = {
        prefix = "■",
        spacing = 2,
        source = "if_many"
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
        scope = "cursor"
      }
    })
  '';
}

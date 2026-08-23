{ lib, ... }:
{
  programs.nixvim = {
    enable = true;
    wrapRc = true;

    imports = [
      ./mini.nix # Текстовые движки Mini.nvim (ai, surround, pairs, splitjoin, align, move)
      ./snacks.nix # Современный UI и QoL стек Snacks.nvim
      ./languages.nix # LSP и Conform форматтеры
      ./completion.nix # Автокомплит
      ./flash.nix # Flash навигация
      ./keymaps.nix # Кастомные хоткеи
      ./opts.nix # Опции редактора
      ./autocmds.nix # Автокоманды
    ];

    # Treesitter для подсветки синтаксиса
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };
    plugins.ts-context-commentstring.enable = true;

    # Which-key с красивыми иконками и группами меню
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
            { pattern = "code"; icon = " "; color = "cyan"; }
            { pattern = "format"; icon = "󰉢 "; color = "cyan"; }
            { pattern = "rename"; icon = "󰑕 "; color = "orange"; }
            { pattern = "git"; icon = "󰊢 "; color = "orange"; }
            { pattern = "find"; icon = " "; color = "green"; }
            { pattern = "file"; icon = "󰈔 "; color = "azure"; }
            { pattern = "buffer"; icon = "󰈚 "; color = "blue"; }
            { pattern = "diagnostics"; icon = "󰒡 "; color = "red"; }
            { pattern = "terminal"; icon = " "; color = "purple"; }
            { pattern = "window"; icon = " "; color = "yellow"; }
            { pattern = "goto"; icon = "󰌹 "; color = "magenta"; }
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
        ];
      };
    };

    # Git Signs в колонке статуса и инлайн blame
    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add = { text = "▎"; };
          change = { text = "▎"; };
          delete = { text = ""; };
          topdelete = { text = ""; };
          changedelete = { text = "▎"; };
          untracked = { text = "┆"; };
        };
        signs_staged = {
          add = { text = "▎"; };
          change = { text = "▎"; };
          delete = { text = ""; };
          topdelete = { text = ""; };
          changedelete = { text = "▎"; };
          untracked = { text = "┆"; };
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

    # Отключаем медленный встроенный matchparen
    globals.loaded_matchparen = 1;

    # Нативные ускорения Nixvim
    luaLoader.enable = true;
    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        plugins = true;
      };
    };

    extraConfigLua = ''
      vim.o.winborder = "single"

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
          border = "single",
          source = "always",
          header = "",
          prefix = "",
          focusable = true,
          scope = "cursor"
        }
      })
    '';
  };
}

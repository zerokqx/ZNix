{
  plugins.mini-icons = {
    enable = true;
    mockDevIcons = true;
    settings = {
      directory = {
        "__tests__" = {
          hl = "MiniIconsAzure";
          glyph = "";
        };
      };
      extension = {
        "test.ts" = {
          hl = "MiniIconsAzure";
          glyph = "󰙨";
        };

        "test.tsx" = {
          hl = "MiniIconsAzure";
          glyph = "󰙨";
        };

        "test.js" = {
          hl = "MiniIconsAzure";
          glyph = "󰙨";
        };
        "test.jsx" = {
          hl = "MiniIconsAzure";
          glyph = "󰙨";
        };

        js = {
          hl = "MiniIconsYellow";
        };
        jsx = {
          hl = "MiniIconsYellow";
        };
        mjs = {
          hl = "MiniIconsYellow";
        };
        cjs = {
          hl = "MiniIconsYellow";
        };
      };
      file = {
        "index.ts" = {
          hl = "MiniIconsGreen";
        };

        "default.nix" = {
          hl = "MiniIconsGreen";
        };

        "index.js" = {
          hl = "MiniIconsGreen";
        };

        "index.jsx" = {
          hl = "MiniIconsGreen";
        };
        "index.tsx" = {
          hl = "MiniIconsGreen";
        };
        "bun.lock" = {
          glyph = "";
          hl = "MiniIconsYellow";
        };
        "vite.config.ts" = {
          glyph = "";
          hl = "MiniIconsPurple";
        };
        "eslint.config.js" = {
          glyph = "";
          hl = "MiniIconsPurple";
        };
        "postcss.config.cjs" = {
          glyph = "";
          hl = "MiniIconsRed";
        };
        "tsconfig.json" = {
          glyph = "";
        };
      };
    };

  };
}

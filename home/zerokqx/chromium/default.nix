{
  config,
  lib,
  pkgs,
  ...
}:

let
  devtoolsEnabled = config.programs.chromium.enable && config.programs.chromium.devtools.enable;
  themed = config.stylix.enable && config.stylix.targets.chromium-devtools.enable;
  paletteCss = pkgs.writeText "chromium-devtools-stylix.css" ''
    :root:root {
      ${lib.concatMapStringsSep "\n" (name: "--znix-${name}: #${config.lib.stylix.colors.${name}};") [
        "base00"
        "base01"
        "base02"
        "base03"
        "base04"
        "base05"
        "base06"
        "base07"
        "base08"
        "base09"
        "base0A"
        "base0B"
        "base0C"
        "base0D"
        "base0E"
        "base0F"
      ]}
      --znix-font-sans: ${builtins.toJSON config.stylix.fonts.sansSerif.name}, sans-serif;
      --znix-font-mono: ${builtins.toJSON config.stylix.fonts.monospace.name}, monospace;
      color-scheme: ${if config.stylix.polarity == "light" then "light" else "dark"};
    }
  '';
  frontend = pkgs.callPackage ./frontend/package.nix {
    chromium = config.programs.chromium.package;
    paletteCss = if themed then paletteCss else null;
  };

  defaultBookmarks = [
    {
      name = "Youtube";
      toolbar = true;
      bookmarks = [
        {
          name = "Video";
          url = "https://youtube.com/";
        }
      ];
    }
    {
      name = "Localhost";
      toolbar = true;
      bookmarks = [
        {
          name = "localhost:3000 (React / Next)";
          url = "http://localhost:3000";
        }
        {
          name = "localhost:3001";
          url = "http://localhost:3001";
        }
        {
          name = "localhost:5173 (Vite)";
          url = "http://localhost:5173";
        }
        {
          name = "localhost:5174";
          url = "http://localhost:5174";
        }
        {
          name = "localhost:8000 (Python / FastAPI / Django)";
          url = "http://localhost:8000";
        }
        {
          name = "localhost:8080 (Backend / Spring / Dev)";
          url = "http://localhost:8080";
        }
        {
          name = "localhost:8081";
          url = "http://localhost:8081";
        }
        {
          name = "localhost:4200 (Angular)";
          url = "http://localhost:4200";
        }
        {
          name = "localhost:5000 (Flask / .NET)";
          url = "http://localhost:5000";
        }
        {
          name = "localhost:4000 (GraphQL / Express)";
          url = "http://localhost:4000";
        }
        {
          name = "localhost:9000 (MinIO / PHP)";
          url = "http://localhost:9000";
        }
      ];
    }
    {
      name = "NixOS";
      toolbar = true;
      bookmarks = [
        {
          name = "MyNixOS";
          url = "https://mynixos.com/";
        }
        {
          name = "Nixpkgs";
          url = "https://search.nixos.org/packages";
        }
      ];
    }
    {
      name = "AI";
      toolbar = true;
      bookmarks = [
        {
          name = "Grok";
          url = "https://grok.com/";
        }
        {
          name = "Perplexity";
          url = "https://www.perplexity.ai";
        }
        {
          name = "ChatGPT";
          url = "https://chatgpt.com/";
        }
        {
          name = "Gemini";
          url = "https://gemini.google.com";
        }
      ];
    }
    {
      name = "Music";
      toolbar = true;
      bookmarks = [
        {
          name = "VK Music";
          url = "https://vk.com/music";
        }
      ];
    }
    {
      name = "Marketplaces";
      toolbar = true;
      bookmarks = [
        {
          name = "Ozon";
          url = "https://www.ozon.ru/";
        }
      ];
    }
  ];

  # Convert bookmarks to Chromium ManagedBookmarks policy format
  chromiumManagedBookmarks = map (folder: {
    name = folder.name;
    children = map (bm: {
      name = bm.name;
      url = bm.url;
    }) folder.bookmarks;
  }) defaultBookmarks;
in
{
  options.programs.chromium.devtools.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Use the local ZNix DevTools frontend with rounded controls and Lucide icons.";
  };
  options.stylix.targets.chromium-devtools.enable =
    config.lib.stylix.mkEnableTarget "Chromium DevTools" true;

  config = {
    xdg.dataFile."chromium/devtools" = lib.mkIf devtoolsEnabled {
      source = frontend;
    };

    xdg.configFile."chromium/policies/managed/znix.json".text = builtins.toJSON (
      {
        BookmarkBarEnabled = true;
        ManagedBookmarks = chromiumManagedBookmarks;
      }
      // lib.optionalAttrs config.stylix.enable {
        BrowserThemeColor = config.lib.stylix.colors.withHashtag.base00;
      }
    );

    programs.chromium = {
      enable = true;
      package = pkgs.chromium.override {
        enableWideVine = true;
        # nixos-26.05 ships an old CDM that license servers reject (DRM_FAILED_LICENSE_REQUEST)
        widevine-cdm = pkgs.widevine-cdm.overrideAttrs (_: rec {
          version = "4.10.3050.0";
          src = pkgs.fetchurl {
            url = "https://edgedl.me.gvt1.com/edgedl/release2/chrome_component/bywu6vkyg6gmcthxdaetzfkptm_${version}/oimompecagnajdejgnnjijobebaeigek_${version}_linux_aduyhcxcs7a2znuo6ss5tffn5jpa.crx3";
            hash = "sha512-5Xiy7tesiH4T79VZ6RfkiOzkO+tJ20ChM8GPV7+fbtXaVDRTTnD3/Dz07v25x2YWS2VZxRPhc46JnYTXlD1Xeg==";
          };
        });
      };

      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--gtk-version=4"
      ]
      ++ lib.optional devtoolsEnabled "--custom-devtools-frontend=file://${frontend}";

      extensions = [
        # mlomiejdfkolichcflejclcbmpeaniij: Ghostery
        { id = "mlomiejdfkolichcflejclcbmpeaniij"; }
        # pkehgijcmpdhfbdbbnkijodmdjhbjlgp: Privacy Badger
        { id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"; }
        # fmkadmapgofadopljbjfkapdkoienihi: React Developer Tools
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; }
        # nngceckbapebfimnlniiiahkandclblb: Bitwarden Password Manager
        { id = "nngceckbapebfimnlniiiahkandclblb"; }
        # djflhoibgkdhkhhcedjiklpkjnoahfmg: User-Agent Switcher for Chrome
        { id = "djflhoibgkdhkhhcedjiklpkjnoahfmg"; }
        # eimadpbcbfnmbkopoojfekhnkhdbieeh: Dark Reader
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }
      ];
    };
  };
}

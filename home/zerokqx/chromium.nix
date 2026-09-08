{ config, lib, pkgs, ... }:

let
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
  xdg.configFile."chromium/policies/managed/znix.json".text = builtins.toJSON {
    BrowserThemeColor = config.lib.stylix.colors.withHashtag.base00;
    BookmarkBarEnabled = true;
    ManagedBookmarks = chromiumManagedBookmarks;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.chromium;

    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--gtk-version=4"
    ];

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
}

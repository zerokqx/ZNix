{
  config,
  inputs,
  pkgs,
  ...
}:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  programs.firefox = {
    package = inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
    enable = true;

    profiles.default = {
      isDefault = true;
      bookmarks = {
        force = true;
        settings = [
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
                name = "localhost:5173";
                url = "http://localhost:5173";
              }

              {
                name = "localhost:3000";
                url = "http://localhost:3000";
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
      };
      settings = {
        "intl.accept_languages" = "ru, en-US, en";
      };
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;

      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;

      DisplayMenuBar = "default-off";
      SearchBar = "unified";

      ExtensionSettings = {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };

        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };

        "firefox@ghostery.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ghostery/latest.xpi";
          installation_mode = "force_installed";
        };

        "postwoman-firefox@postwoman.io" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/hoppscotch/latest.xpi";
          installation_mode = "force_installed";
        };

        "{cf3dba12-a848-4f68-8e2d-f9fadc0721de}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/lighthouse/latest.xpi";
          installation_mode = "force_installed";
        };

        "@storageexplorer" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/local-storage-explorer/latest.xpi";
          installation_mode = "force_installed";
        };

        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };

        "@react-devtools" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
          installation_mode = "force_installed";
        };

        "extension@redux.devtools" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/reduxdevtools/latest.xpi";
          installation_mode = "force_installed";
        };

        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };

        "tanstack-query-devtools@borysov.dev" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tanstack-query-devtools/latest.xpi";
          installation_mode = "force_installed";
        };

        "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
          installation_mode = "force_installed";
        };

        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };

        "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
          installation_mode = "force_installed";
        };

        "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
          installation_mode = "force_installed";
        };

      };

      Preferences = {
        "browser.contentblocking.category" = {
          Value = "strict";
          Status = "locked";
        };
        "extensions.pocket.enabled" = lock-false;
        "extensions.screenshots.disabled" = lock-true;
        "browser.topsites.contile.enabled" = lock-false;
        "browser.formfill.enable" = lock-false;
        "browser.search.suggest.enabled" = lock-false;
        "browser.search.suggest.enabled.private" = lock-false;
        "browser.urlbar.suggest.searches" = lock-false;
        "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
        "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
      };
    };
  };
}

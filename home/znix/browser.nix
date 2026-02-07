{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;

let
  cfg = config.znix.browser;
in

{
  options.znix.browser = {
    enable = mkEnableOption "browser configuration with Firefox";

    installExtensions = mkOption {
      type = types.bool;
      default = true;
      description = "Install default extensions";
    };

    target = mkOption {
      type = types.enum [ "firefox" ];
      default = "firefox";
      description = "Browser for setting. Support - firefox";
    };

    profile = mkOption {
      type = types.str;
      default = "default";
      description = "Profile in firefox";
    };

    bookmarks = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default bookmarks or not. Default true";
    };

    package = mkOption {
      type = types.package;
      default = inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
      description = "Firefox package to use";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = mkIf (cfg.target == "firefox") {
      package = cfg.package;
      enable = true;

      profiles.${cfg.profile} = {
        isDefault = true;

        bookmarks = mkIf cfg.bookmarks {
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
          Status = "locked";
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

        ExtensionSettings = mkIf cfg.installExtensions {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            # Bitwarden
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };

          "addon@darkreader.org" = {
            # Dark Reader
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };

          "firefox@ghostery.com" = {
            # Ghostery
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ghostery/latest.xpi";
            installation_mode = "force_installed";
          };

          "postwoman-firefox@postwoman.io" = {
            # Hoppscotch
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/hoppscotch/latest.xpi";
            installation_mode = "force_installed";
          };

          "{cf3dba12-a848-4f68-8e2d-f9fadc0721de}" = {
            # Lighthouse
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/lighthouse/latest.xpi";
            installation_mode = "force_installed";
          };

          "@storageexplorer" = {
            # Local Storage Explorer
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/local-storage-explorer/latest.xpi";
            installation_mode = "force_installed";
          };

          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            # Privacy Badger
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };

          "@react-devtools" = {
            # React DevTools
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
            installation_mode = "force_installed";
          };

          "extension@redux.devtools" = {
            # Redux DevTools
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/reduxdevtools/latest.xpi";
            installation_mode = "force_installed";
          };

          "sponsorBlocker@ajay.app" = {
            # SponsorBlock
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };

          "tanstack-query-devtools@borysov.dev" = {
            # TanStack Query DevTools
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tanstack-query-devtools/latest.xpi";
            installation_mode = "force_installed";
          };

          "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
            # Traduzir
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
            installation_mode = "force_installed";
          };

          "uBlock0@raymondhill.net" = {
            # uBlock Origin
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };

          "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = {
            # User-Agent Switcher
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/user-agent-string-switcher/latest.xpi";
            installation_mode = "force_installed";
          };

          "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" = {
            # YouTube NonStop
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = {
            Value = false;
            Status = "locked";
          };
          "extensions.screenshots.disabled" = {
            Value = true;
            Status = "locked";
          };
          "browser.topsites.contile.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.formfill.enable" = {
            Value = false;
            Status = "locked";
          };
          "browser.search.suggest.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.search.suggest.enabled.private" = {
            Value = false;
            Status = "locked";
          };
          "browser.urlbar.suggest.searches" = {
            Value = false;
            Status = "locked";
          };
          "browser.urlbar.showSearchSuggestionsFirst" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.section.topstories" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.snippets" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.showSponsored" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.system.showSponsored" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = {
            Value = false;
            Status = "locked";
          };
        };
      };
    };
  };
}

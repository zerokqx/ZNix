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
      configPath = ".mozilla/firefox";

      profiles.${cfg.profile} = {
        isDefault = true;
        extensions.force = true;

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
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
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

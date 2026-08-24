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

          # 1. Полное отключение телеметрии и сбора данных (Mozilla Telemetry & Health Report)
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "data:,";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "toolkit.coverage.endpoint.base" = "";

          # 2. Отключение краш-репортов и отправки дампов памяти
          "breakpad.reportURL" = "";
          "browser.tabs.crashReporting.sendReport" = false;
          "browser.crashReports.unsubmittedCheck.enabled" = false;
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

          # 3. Отключение Normandy / Экспериментов / Исследований (Shield / Studies)
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";
          "app.shield.optoutstudies.enabled" = false;
          "experiments.active.enabled" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;

          # 4. Отключение скрытого пинг-трекинга (Hyperlink Ping & Beacon API)
          "browser.send_pings" = false;
          "beacon.enabled" = false;

          # 5. Отключение предзагрузки ссылок и DNS (Network Prefetch / Speculative Connection)
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.dns.disablePrefetchFromHTTPS" = true;
          "network.predictor.enabled" = false;
          "network.predictor.enable-prefetch" = false;
          "network.http.speculative-parallel-limit" = 0;
          "browser.places.speculativeConnect.enabled" = false;

          # 6. Отключение телеметрии поиска и адресной строки
          "browser.urlbar.eventTelemetry.enabled" = false;
          "browser.ping-centre.telemetry" = false;
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

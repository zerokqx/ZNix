{ config, pkgs, ... }:

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
                name = "Music";
                url = "https://music.youtube.com/";
              }
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

        "devtools.theme" = "dark"; # или "light"
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "intl.accept_languages" = "ru, en-US, en";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''

                      :root {
                        --black-color-1: black;
                        --black-color-2: #050505;
                        --black-color-3: #090909;
                        --white-color-1: white;
                        --white-color-2: #c7c6ce12;
                        --max-border-radius-value: 10px;
                        --blue-color-1: #0063ff;
                        --blue-color-2: #1d72fe;
                        --color-accent-primary: var(--blue-color-2) !important;
                        --toolbar-field-background-color: var(--black-color-3) !important;
                        --toolbar-field-focus-background-color: var(--black-color-3) !important;
                        --tab-selected-bgcolor: var(--black-color-3) !important;
                        --tab-selected-outline-color: #f0f0f026 !important;
                        --tab-border-radius: var(--max-border-radius-value) !important;
                        --toolbar-bgcolor: var(--black-color-2) !important;
                        --inactive-titlebar-opacity: 1 !important;
                        --toolbox-bgcolor: var(--black-color-3) !important;
                        --toolbarbutton-border-radius: var(--max-border-radius-value) !important;
                        --toolbox-bgcolor-inactive: var(--toolbox-bgcolor) !important;
                        --urlbar-box-bgcolor: transparent !important;
                        --panel-background: var(--black-color-3) !important;
                        --panel-color: var(--white-color-1) !important;
                        --arrowpanel-background: var(--black-color-3) !important;
                        --arrowpanel-border-radius:var(--max-border-radius-value)!important;
                        --arrowpanel-border-color: var(--white-color-2) !important;
                        --arrowpanel-color: var(--white-color-1) !important;
                        --background-color-canvas: var(--black-color-3) !important;
                      }

                      #TabsToolbar-customization-target {
                        counter-reset: tab-counter;
                      }

                      .tabbrowser-tab:not([hidden]) {
                        counter-increment: tab-counter;
                      }

                      #alltabs-button > .toolbarbutton-badge-stack > .toolbarbutton-icon {
                        opacity: 0;
                      }

                      #alltabs-button > .toolbarbutton-badge-stack::before {
                        content: counter(tab-counter);
                        display: flex;
                        grid-area: 1/1;
                        justify-content: center;
                        color: var(--toolbarbutton-icon-fill);
                        border-bottom: 1px solid;
                        contain: inline-size;
                      }

                      /* Icon transitions and scaling */
                      .urlbar-icon,
                      .toolbarbutton-icon,
                      .tab-close-button,
                      .downloadIconShow > .button-box > .button-icon,
                      .menuitem-iconic is(.menu-iconic-icon,.menu-icon),
                      #downloads-indicator-icon,
                      .urlbar-input-container [role="button"] image {
                        transition: transform 83ms linear !important;
                      }

                      toolbar .toolbarbutton-1 > .toolbarbutton-icon {
                        transition: padding 83ms linear !important;
                      }

                      /* Default icon scale */
                      .urlbar-input-container [role="button"] image,
                      .tab-close-button,
                      .downloadIconShow > .button-box > .button-icon,
                      .unified-extensions-item-menu-button > .toolbarbutton-icon,
                      #downloads-button #downloads-indicator-icon,
                      toolbarbutton#scrollbutton-up > .toolbarbutton-icon,
                      toolbar .toolbarbutton-1 > .toolbarbutton-badge-stack > .toolbarbutton-icon,
                      .menuitem-iconic is(.menu-iconic-icon,.menu-icon),
                      .urlbar-icon {
                        transform: scale(0.8) !important;
                      }

                      toolbarbutton#scrollbutton-down > .toolbarbutton-icon {
                        transform: scale(-0.8) !important;
                      }

                      toolbar .toolbarbutton-1 > .toolbarbutton-icon {
                        padding: calc(var(--toolbarbutton-inner-padding) + 2px) !important;
                      }

                      /* Hover states */
                      .urlbar-input-container [role="button"]:not([disabled]):hover image,
                      .tab-close-button:hover,
                      .downloadIconShow:hover > .button-box > .button-icon,
                      #downloads-button:not([disabled]):hover #downloads-indicator-icon,
                      toolbarbutton#scrollbutton-up:not([disabled]):hover > .toolbarbutton-icon,
                      toolbar
                        .toolbarbutton-1:not([disabled]):hover
                        > .toolbarbutton-badge-stack
                        > .toolbarbutton-icon,
                      .menuitem-iconic:not([disabled]):hover :is(.menu-iconic-icon, .menu-icon),
                      .urlbar-page-action:hover > .urlbar-icon {
                        transform: none !important;
                      }

                      toolbarbutton#scrollbutton-down:not([disabled]):hover > .toolbarbutton-icon {
                        transform: scale(-1) !important;
                      }

                      toolbar .toolbarbutton-1:not([disabled]):hover > .toolbarbutton-icon {
                        padding: var(--toolbarbutton-inner-padding) !important;
                      }

                      #nav-bar {
                        margin: 6px !important;
                        border-radius: var(--max-border-radius-value);
                      }

                      toolbar .toolbarbutton-1 {
                        color: var(--blue-color-2) !important;
                      }

                      #TabsToolbar .toolbarbutton-1 {
                        color: var(--blue-color-1) !important;
                      }

                      .buttons-wrapper {
                        background-color: var(--black-color-3) !important;
                      }
                      *{
                -moz-appearance: none !important;

                      }

        :root, body, * {
          
        --uc-background-color: rgba(28, 27, 34,1);
        --uc-border-color: rgba(28, 27, 34,0.5);
        --uc-text-color: rgb(255, 255, 255);
        --uc-border-radius: 10px;
        --uc-selected: rgba(0,0,0,1);
        --uc-hover: rgba(0,0,0,0.7);
        }

        /*
        Example of removing context menu items below;
        Refer to SMW for an all in one place reference-library: https://github.com/stonecrusher/simpleMenuWizard
        */

        #context-take-screenshot
        #context-sep-screenshots,
        #context-sendimage,
        #context-setDesktopBackground,
        #context-sep-setbackground,
        #context-openlinkinusercontext-menu
            {
                display: none !important;
            }

        #context-pocket,
        #context-savelinktopocket,
        #tabContextMenu #context_duplicateTab,         
        #tabContextMenu #context_duplicateTabs,
        #tabContextMenu #context_bookmarkSelectedTabs
            {
                display: none !important;
            }

        /*
        Apply your variables, style, color, etc, to the context menu
        */

        menupopup, panel {
          color-scheme: light dark;
          --panel-background: var(--uc-background-color) !important;
          --panel-color: var(--uc-text-color) !important;
          --panel-border-radius: var(--uc-border-radius) !important;
          --panel-border-color: var(--uc-border-color) !important;
          --panel-shadow: 0 0 var(---uc-border-color) hsla(0,0%,0%,.2); 
        }

        menuitem:hover{
          background-color: var(--uc-hover) !important;
          color: var(--uc-text-color) !important;
         }

        menu:where([_moz-menuactive="true"]:not([disabled="true"])),
        menuitem:where([_moz-menuactive="true"]:not([disabled="true"])){
          background-color: var(--uc-selected) !important;
          color: var(--uc-text-color) !important;
        }
        @soulhotel
        Author
        soulhotel
        commented
        on Jun 12, 2024
        •

      '';
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

        # Тема (у тем тоже тип = "theme", но ставятся как addon)
        "{7cbdf3df-936d-4b13-811f-320bf981f801}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/dark/latest.xpi";
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

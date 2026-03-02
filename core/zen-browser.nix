{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
      # если хочешь жёстко форсить как в твоём firefox policies:
      # installation_mode = "force_installed";
    };
  };

  prefs = {
    # твои prefs
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
  };

  # Расширения из твоего "firefox" конфига
  extensions = [
    (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
    (extension "darkreader" "addon@darkreader.org")
    (extension "ghostery" "firefox@ghostery.com")
    (extension "hoppscotch" "postwoman-firefox@postwoman.io")
    (extension "lighthouse" "{cf3dba12-a848-4f68-8e2d-f9fadc0721de}")
    (extension "local-storage-explorer" "@storageexplorer")
    (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
    (extension "react-devtools" "@react-devtools")
    (extension "reduxdevtools" "extension@redux.devtools")
    (extension "sponsorblock" "sponsorBlocker@ajay.app")
    (extension "tanstack-query-devtools" "tanstack-query-devtools@borysov.dev")
    (extension "traduzir-paginas-web" "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}")
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "user-agent-string-switcher" "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}")
    (extension "youtube-nonstop" "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}")
  ];
in
{
  environment.systemPackages = [
    (pkgs.wrapFirefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
      {
        extraPrefs = lib.concatLines (
          lib.mapAttrsToList (
            name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
          ) prefs
        );

        extraPolicies = {
          DisableTelemetry = true;

    
          ExtensionSettings = builtins.listToAttrs extensions;

          SearchEngines = {
            Default = "ddg";
            Add = [
              {
                Name = "nixpkgs packages";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@np";
              }
              {
                Name = "NixOS options";
                URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@no";
              }
              {
                Name = "NixOS Wiki";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@nw";
              }
              {
                Name = "noogle";
                URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                IconURL = "https://noogle.dev/favicon.ico";
                Alias = "@ng";
              }
            ];
          };
        };
      }
    )
  ];
}

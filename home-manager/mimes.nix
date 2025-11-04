{ pkgs, ... }:

{
  home-manager.users.zerok = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "firefox-devedition.desktop";
        "x-scheme-handler/https" = "firefox-devedition.desktop";
        "x-scheme-handler/about" = "firefox-devedition.desktop";
        "x-scheme-handler/unknown" = "firefox-devedition.desktop";
      };
    };
  };
}

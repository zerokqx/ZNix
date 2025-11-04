{ lib, ... }:
let
  obsidianPath = "/home/zerok/Documents/obsidian";
  user = "zerok";
  certs = import ../../utils/getCerts.nix {

    service = "syncthing";
    host = "desktop";
  };
in {
  services.syncthing = {
    inherit user;

    overrideDevices = true;
    overrideFolders = true;
    group = "users";
    enable = true;
    cert = lib.mkDefault certs.cert;
    key = lib.mkDefault certs.key;
    settings = {
      gui = { inherit user; };
      folders = { "Obsidian" = { path = obsidianPath; }; };
    };
    openDefaultPorts = true;
  };
}

let
  obsidianPath = "/home/zerok/Documents/obsidian";
  user = "zerok";
  cerst = import ../../utils/getCerts.nix {
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
    inherit (cerst) cert key;
    settings = {
      gui = { inherit user; };
      # devices = { "My Notebook" = { id = deviceId; }; };
      folders = {
        "Obsidian" = {
          path = obsidianPath;
          devices = [ ];
        };
      };
    };
    openDefaultPorts = true;
  };
}

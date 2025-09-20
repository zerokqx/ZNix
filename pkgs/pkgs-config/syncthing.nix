let
  obsidianPath = "/home/zerok/Documents/obsidian";
  user = "zerok";
  pathToCertKey = ../../certs/syncthing;
  certFile = builtins.toString pathToCertKey + "/cert.pem";
  keyFile = builtins.toString pathToCertKey + "/key.pem";
in {
  services.syncthing = {
    inherit user;
    group = "users";
    enable = true;
    cert = certFile;
    key = keyFile;
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

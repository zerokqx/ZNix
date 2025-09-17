{ config, ... }: {

  services.syncthing = let

    obsidianPath = /home/zerok/Documents/obsidian;
    user = "zerok";
    pathToCertKey = ../certs/syncthing;
    inherit (builtins) toString;
  in {
    inherit user;
    group = "users";
    enable = true;
    cert = "${toString pathToCertKey}/cert.pem";
    key = "${toString pathToCertKey}/key.pem";

    settings = {
      gui = {
        inherit user;
        password = "${pathToCertKey}/password";
      };
      devices = {
        "My Notebook" = { id = "${pathToCertKey}/notebook-id"; };
      }; # FIX: Syncthing not see this devices
      folders = {
        "Obsidian" = {
          path = toString obsidianPath; # FIX: Path don't read in syncthing
          devices = [ "My Notebook" ];
        };
      };
    };
    openDefaultPorts = true;

  };
}

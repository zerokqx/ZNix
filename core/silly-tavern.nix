{
  pkgs,
  lib,
  config,
  ...
}:
let

  cfg = config.ai.sillytavern;
in
{
  options.ai.sillytavern = {
    enable = lib.mkEnableOption "Silly Tavern enable";
    ollamaEnable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ollama Provider";

    };
    name = lib.mkOption {
      type = lib.types.str;
      default = "zerokqx";
      description = "Name from Silly Tavern";
    };

    mobileServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Create mobile cli command. If enable server sillytavern not launch";

    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      lib.optionals cfg.mobileServer [
        sillytavern
        (writeShellScriptBin "stMobile" ''
          sillytavern --listen --port 8000 --whitelist
        '')
      ];

    services = {
      ollama.enable = lib.mkDefault cfg.ollamaEnable;
      sillytavern = lib.mkIf (cfg.mobileServer == false) {
        port = 8000;
        enable = cfg.enable;
        whitelist = false;
        listen = true;
      };
    };
  };
}

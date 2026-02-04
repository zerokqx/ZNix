{ lib, config, ... }:

lib.mkIf (config.plugins.snacks.settings.explorer.enabled == false) {

  plugins.mini-files = {
    settings = {
      options = {
        permanent_delete = false;
        use_as_default_explorer = true;
      };
      max_number = lib.nixvim.mkRaw "math.huge";
      preview = false;
      width_focus = 50;
      width_nofocus = 10;
      width_preview = 25;
    };
  };
}

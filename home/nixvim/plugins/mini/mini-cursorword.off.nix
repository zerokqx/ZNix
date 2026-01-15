{ lib, config, ... }:

{
  plugins.mini-cursorword.enable =
    lib.mkIf (config.plugins.snacks.enable or false)
    && (config.plugins.snacks.settings.word.enabled or false) false true;
}

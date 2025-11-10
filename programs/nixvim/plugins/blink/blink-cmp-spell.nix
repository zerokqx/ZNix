{ lib, config, ... }:

lib.mkIf config.plugins.blink-cmp.enable {
  plugins.blink-cmp-spell.enable = builtins.trace "Spell провайдер включён (автодополнение орфографии)" true;

  plugins.blink-cmp.settings.sources.providers.spell = {
    module = "blink-cmp-spell";
    name = "Spell"; score_offset = 100;
    opts = {
      # Опционально: можно сразу включить русский + английский
      languages = [
        "en"
        "ru"
      ];
      # Или только один:
      # languages = [ "en" ];
    };
  };
}

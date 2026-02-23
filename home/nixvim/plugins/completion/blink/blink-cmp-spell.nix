{ lib, config, ... }:

lib.mkIf config.plugins.blink-cmp.enable {
  plugins.blink-cmp-spell.enable = builtins.trace "Spell провайдер включён (автодополнение орфографии)" true;

  plugins.blink-cmp.settings.sources.providers.spell = {
    module = "blink-cmp-spell";
    name = "Spell";
    score_offset = 100;
    opts = {
      languages = [
        "en"
        "ru"
      ];
    };
  };
}

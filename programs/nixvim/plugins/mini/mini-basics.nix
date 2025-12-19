{ ... }:
{
  plugins.mini-basics = {
    enable = true;
    settings = {
      options = {
        basic = true; # Базовые опции - оставь true
        extra_ui = true; # Включи это для красивого UI
        win_borders = "rounded"; # Или "single"  "double"
      };
      mappings = {
        basic = true;
        windows = true; # Навигация окнами <C-hjkl>
        option_toggle_prefix = "\\"; # \w = toggle wrap, \n = toggle numbers
      };
      autocommands = {
        basic = true;
        relnum_in_visual_mode = true; # Релативные номера в visual режиме
      };
      silent = false;
    };
  };
}

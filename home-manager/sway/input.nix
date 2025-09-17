let notebook = import ../../itNotebook.nix;
in {
  "type:keyboard" = {
    xkb_layout = "us,ru";
    xkb_options = "grp:win_space_toggle,caps:escape";

  };
  "type:touchpad" = {
    tap = "enabled"; # включить тап
    tap_button_map = "lrm"; # кнопки маппинга тапов
    dwt = "enabled"; # отключать тачпад при наборе
    dwtp = "enabled";
    natural_scroll = "enabled"; # инвертировать скролл
  };
}

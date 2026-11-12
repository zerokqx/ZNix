---
name: stylix
description: "Менять общую тему Stylix, локальный target Caelestia или тему SDDM в ZNix."
---

# Stylix в ZNix

Общие defaults палитры и шрифтов находятся в `lib/stylix-theme.nix`. Их читают
Home Manager в `home/zerokqx/znix/theme.nix` и системный SDDM в `core/sddm.nix`.
Не копируйте Base16-цвета в новые модули или QML: берите
`config.lib.stylix.colors` и `withHashtag` в формате, которого требует цель.

`home/zerokqx/znix/stylix-celestia.nix` — обычный Home Manager module, поэтому
он вручную повторяет documented guard Stylix: тема возникает только при
`stylix.enable`, `stylix.targets.celestia.enable` и включённой Caelestia.
Target использует `config.lib.stylix.mkEnableTarget`; `mkTarget` здесь недоступен.
Он генерирует неизменяемую JSON-схему цветов и передаёт путь только выбранной
Caelestia через environment. CLI state пользователя не перезаписывается.

Сопоставление ролей находится в `defaultColours`: base00–base02 — поверхности,
base05/base06 — текст, base03/base04 — границы и вторичные элементы,
base0D/base0C/base0E — акценты, base08 — ошибка, base0B — успех. При добавлении
компонента используйте существующую семантическую роль; новую роль добавляйте
только после проверки фактического интерфейса upstream и обновляйте проверку
реального JSON в `tests/celestia-stylix.nix`.

Цвета Caelestia — bare `RRGGBB`. Точечно переопределяйте роли без `#`, например:

```nix
stylix.targets.celestia.colours.primary = "7aa2f7";
```

Значения target и его шрифты/прозрачность заданы `mkDefault`, поэтому обычное
пользовательское назначение соответствующего `programs.caelestia.settings`
имеет приоритет. Отключайте target явно через
`stylix.targets.celestia.enable = false;`; при `stylix.enable = false` он не
создаёт ни конфигурации, ни окружения.

Caelestia получает схему и, когда задан `stylix.image`, wallpaper через
локальный патч пакета. Не меняйте этот патч, не сверив upstream QML: он нужен,
чтобы не создавать watcher и не владеть mutable state CLI. При обновлении input
Caelestia проверьте, что patch по-прежнему применяется, затем выполните:

```sh
nix build --no-link --no-update-lock-file \
  .#checks.x86_64-linux.celestia-stylix
./scripts/check.sh all
```

Путь схемы передаётся в environment Hyprland поколения сессии. После
авторизованной активации темы или переключения shell выйдите из сессии и войдите
снова; перезапуск одной Caelestia не гарантирует обновление либо удаление этого
environment.

При конфликте сначала проверьте эффективные значения `stylix.enable`,
`stylix.targets.celestia.enable`, `programs.caelestia.enable` и
`programs.caelestia.settings` через `nix eval`, затем путь схемы в
`wayland.windowManager.hyprland.settings.env` и содержимое JSON. Если они верны,
сравните окружение запущенной оболочки с новым поколением. Не исправляйте
расхождение перезаписью CLI state. Системный `stylix.enable` наследуется
встроенным Home Manager как default; явный пользовательский override сильнее.

Новый локальный target подключайте обычным явным import на уровне владельца
приложения. Используйте доступный в закреплённой версии `mkEnableTarget`,
явные условия включения и `mkDefault` для оформления. Не переносите внутренний
autoload API Stylix в произвольный модуль. Проверяйте включение, оба отключения
и пользовательские overrides на сгенерированной конфигурации приложения.

SDDM не наследует Home Manager. Его `theme.conf` генерируется из системного
Stylix в `core/sddm.nix`; `core/sddm-theme/Main.qml` содержит роли, но не
палитру. Проверяйте путь темы через `nix eval` из skill `desktop`. Не называйте
evaluation доказательством работы greeter или PAM/U2F: это проверяется только
отдельным запуском после явного согласования.

# Документація ZNix
<div class="lang-switch">
  <a href="../README.md">English</a> |
  <a href="ru.md">Русский</a> |
  <a href="uk.md">Українська</a> |
  <a href="es.md">Español</a> |
  <a href="de.md">Deutsch</a> |
  <a href="fr.md">Français</a> |
  <a href="pt-br.md">Português (BR)</a> |
  <a href="zh-CN.md">中文</a>
</div>

![Банер](../assets/banner.jpg)

Набір конфігів NixOS/home-manager з поділом на хости. Нижче — що де лежить, кастомні опції, попередження щодо hardware-configuration і як використати або додати хост.

## Фішки
- SwayFX з попередньо налаштованим Noctalia Shell (панель/бар, виходи, автозапуски).
- Neovim через nixvim з плагінами для LSP, автодоповнення, UI/Treesitter, DAP.
- Stylix-тема з кастомними курсорами/іконками та інтеграцією в GTK, fzf, lazygit, noctalia.
- Опційний модуль SillyTavern + Ollama і готовий модуль dev-портів для LAN.

## Приклади

- `fastfetch` + nixvim: ![Приклад 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Приклад 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Структура
- `flake.nix`: вхід; тягне nixpkgs 25.11, home-manager, nixvim, stylix, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: точки входу nixosSystem; підключають `configuration.nix`, свій `hardware-configuration.nix`, хостові модулі (ollama, fprintd/opencode) та HM для користувача `zerok`.
- `configuration.nix`: базовий системний стек; імпортує `core/` і `configs/`.
- `core/`: системні модулі (boot, nixpkgs, мережа, звук, графіка, користувачі тощо) плюс `znix/` для кастомних опцій.
- `configs/`: додаткові твіки (наприклад, `throne.nix`, `zapret.nix`).
- `home/`: конфіг HM для `zerok`; включає swayfx (`home/sway/`), пакети, теми, nixvim (`home/nixvim/`) тощо.

## Кастомні опції
- Система:
  - `znix.monitors.*` (`home/znix/monitors.nix`): карта моніторів (режим/позиція) і вибір для панелі Noctalia.
  - `znix.dev.ports.*` (`core/znix/ports.nix`): відкриває dev TCP-порти на вибраному інтерфейсі (`interface`, `tcpPorts`).
  - `znix.ai.sillytavern.*` (`core/znix/silly-tavern.nix`): вмикає SillyTavern і Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
  - `znix.hardware.fingerprint.goodix.*` (`core/znix/finger-print.nix`): вмикає Goodix (fprintd/TOD).
- Home:
  - `znix.browser.*` (`home/znix/browser.nix`): налаштування Firefox (профіль, розширення, закладки).
  - `znix.theme.*` (`home/znix/theme.nix`): полярність теми, курсор, пакети/назви іконок для stylix.

## Попередження щодо hardware-configuration
- Файли `hosts/*/hardware-configuration.nix` специфічні для машини; **замініть їх** на свої (типово `/etc/nixos/hardware-configuration.nix` після інсталяції).
- Не комітьте чужі hardware-config; тримайте свої локально або приватно.

## Як використати існуючий хост
1) Встановіть NixOS і увімкніть flakes (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Клонуйте репозиторій і замініть `hosts/<target>/hardware-configuration.nix` на свій.
3) Збірка: `sudo nixos-rebuild switch --flake .#desktop` (або `.#laptop`).
4) Швидка перевірка без переключення: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Як додати новий хост
1) Скопіюйте існуючу теку `hosts/<name>/` і покладіть свій `hardware-configuration.nix`.
2) У новому `default.nix` виставте правильний `system` і увімкніть потрібні модулі/оверлеї.
3) Підкоригуйте HM-специфіку (позиція бара noctalia, масштаб шрифтів, layout дисплеїв тощо).
4) Збірка: `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` або `sudo nixos-rebuild switch --flake .#<name>`.

## Нотатки
- home-manager живе всередині модулів NixOS (нема окремого output `homeConfigurations`).
- Нові модулі потрібно явно додавати у відповідні `default.nix` (автоімпорту немає).

# Документация по ZNix
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

![Баннер](../assets/banner.jpg)

Набор NixOS/home-manager конфигов с разделением на хосты. Ниже указано, что где лежит, какие есть кастомные опции, и что нужно сделать перед использованием на своём железе.

## Фишки
- SwayFX с заранее настроенным Noctalia Shell (панель, бар, выводы, автозапуски).
- Neovim через nixvim со сборкой плагинов (LSP, автодополнение, UI/Treesitter, DAP).
- Stylix тема с кастомными курсорами/иконками и интеграцией в GTK, fzf, lazygit, noctalia.
- Flatpak интеграция через nix-flatpak и набор пользовательских пакетов/шрифтов из home-manager.
- Опциональный SillyTavern + Ollama модуль и готовый модуль dev-портов для LAN.

## Примеры

- `fastfetch` + nixvim: ![Пример 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Пример 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Структура
- `flake.nix`: входная точка; подтягивает nixpkgs 25.11, home-manager, nixvim, stylix, nix-flatpak, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: точки входа для сборки (`nixosSystem`); подключают `configuration.nix`, свой `hardware-configuration.nix`, локальные модули (ollama, fprintd/opencode) и home-manager пользователя `zerok`.
- `configuration.nix`: базовый системный стек; подключает `core/` и `configs/`.
- `core/`: системные модули (boot, nixpkgs, сети, звук, графика, пользователи и т.д.) плюс `dev/`, `silly-tavern.nix`, `hardware/`.
- `configs/`: дополнительные настройки (например, `throne.nix`, `zapret.nix`).
- `home/`: home-manager конфиги для `zerok`; включает swayfx (`home/sway/`), пакеты, темы, nixvim (`home/nixvim/`) и т.д.

## Кастомные опции
- Система:
  - `dev.ports.*` (`core/dev/ports.nix`): открывает dev TCP-порты на выбранном интерфейсе (`interface`, `tcpPorts`).
  - `ai.sillytavern.*` (`core/silly-tavern.nix`): включение SillyTavern и Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
- Home:
  - `theme.*` (`home/stylix.nix`): полярность темы, курсоры и иконки (пакеты и названия тем для stylix).

## Предостережение по hardware-configuration
- Файлы `hosts/*/hardware-configuration.nix` сгенерированы под конкретное железо; их **нужно заменить** на свои (обычно лежат в `/etc/nixos/hardware-configuration.nix` после установки).
- Не коммитьте чужие hardware-configuration в основной репозиторий; держите свои копии локально или в приватных оверлеях.

## Как использовать существующий хост
1) Установите NixOS и включите flakes (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Склонируйте репозиторий и подмените `hosts/<target>/hardware-configuration.nix` на свой.
3) Соберите: `sudo nixos-rebuild switch --flake .#desktop` (или `.#laptop`).
4) Для быстрой проверки сборки без переключения: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Как добавить новый хост
1) Скопируйте один из существующих каталогов `hosts/<name>/`, подставьте свой `hardware-configuration.nix`.
2) В новом `default.nix` смените имя системы (`system = "x86_64-linux"` при необходимости) и подключите нужные модули/оверлеи.
3) Обновите специфичные настройки HM (позиция бара noctalia, масштабы шрифтов, layout дисплеев и т.д.).
4) Сборка: `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` или `sudo nixos-rebuild switch --flake .#<name>`.

## Дополнительно
- home-manager конфиги живут внутри модулей NixOS (нет отдельного `homeConfigurations` в output).
- При добавлении новых модулей их нужно явно прописать в соответствующих `default.nix` (авто-импортов нет).

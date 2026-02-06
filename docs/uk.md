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

<style>
:root {
  --znix-bg: #1a1b26;
  --znix-accent: #7aa2f7;
  --znix-accent-soft: #7dcfff;
  --znix-border: #3b4261;
}
a {
  color: var(--znix-accent);
  font-weight: 600;
  text-decoration: none;
  border-bottom: 1px solid var(--znix-border);
  padding-bottom: 1px;
  transition: color 0.2s ease, border-color 0.2s ease;
  border-radius: 0;
}
a:hover {
  color: var(--znix-accent-soft);
  border-color: var(--znix-accent-soft);
}
img {
  border-radius: 0;
  border: 1px solid var(--znix-border);
  box-shadow: 0 6px 30px rgba(26, 27, 38, 0.45);
}
.lang-switch a {
  display: inline-block;
  padding: 6px 10px;
  background: var(--znix-bg);
  border: 1px solid var(--znix-border);
  border-radius: 0;
  margin-right: 6px;
}
</style>

![Банер](../assets/banner.jpg)

Набір конфігів NixOS/home-manager з поділом на хости. Нижче — що де лежить, кастомні опції, попередження щодо hardware-configuration і як використати або додати хост.

## Фішки
- SwayFX з попередньо налаштованим Noctalia Shell (панель/бар, виходи, автозапуски).
- Neovim через nixvim з плагінами для LSP, автодоповнення, UI/Treesitter, DAP.
- Stylix-тема з кастомними курсорами/іконками та інтеграцією в GTK, fzf, lazygit, noctalia.
- Інтеграція Flatpak через nix-flatpak плюс пакети/шрифти з home-manager.
- Опційний модуль SillyTavern + Ollama і готовий модуль dev-портів для LAN.

## Приклади

- `fastfetch` + nixvim: ![Приклад 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Приклад 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Структура
- `flake.nix`: вхід; тягне nixpkgs 25.11, home-manager, nixvim, stylix, nix-flatpak, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: точки входу nixosSystem; підключають `configuration.nix`, свій `hardware-configuration.nix`, хостові модулі (ollama, fprintd/opencode) та HM для користувача `zerok`.
- `configuration.nix`: базовий системний стек; імпортує `core/` і `configs/`.
- `core/`: системні модулі (boot, nixpkgs, мережа, звук, графіка, користувачі тощо) плюс `dev/`, `silly-tavern.nix`, `hardware/`.
- `configs/`: додаткові твіки (наприклад, `throne.nix`, `zapret.nix`).
- `home/`: конфіг HM для `zerok`; включає swayfx (`home/sway/`), пакети, теми, nixvim (`home/nixvim/`) тощо.

## Кастомні опції
- Система:
  - `dev.ports.*` (`core/dev/ports.nix`): відкриває dev TCP-порти на вибраному інтерфейсі (`interface`, `tcpPorts`).
  - `ai.sillytavern.*` (`core/silly-tavern.nix`): вмикає SillyTavern і Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
- Home:
  - `theme.*` (`home/stylix.nix`): полярність теми, курсор, пакети/назви іконок для stylix.

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

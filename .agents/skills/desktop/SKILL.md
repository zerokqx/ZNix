---
name: desktop
description: "Менять ZNix desktop stack: Caelestia, резервный DMS, Hyprland и SDDM без конкурирующих сервисов."
---

# Desktop в ZNix

`home/zerokqx/desktop.nix` выбирает личную оболочку. По умолчанию включена
Caelestia; настройки DMS сохранены, а его enable получает обратное значение.
Его пакеты и конфигурация возвращаются при пересборке резервного варианта. Assertion
не допускает два shell одновременно. Не включайте оба вручную.

Для возврата к DMS добавьте в нужную Home Manager конфигурацию:

```nix
programs.caelestia.enable = false;
```

На NixOS-хосте это находится внутри `home-manager.users.zerok`. Для standalone
Home Manager настройка остаётся в модуле пользователя. После авторизованной
активации выйдите из сессии и войдите снова: оболочка запускается Hyprland через
`exec-once`, а не пользовательский systemd unit.

`home/zerokqx/hyprland/{exec,binds,rules}.nix` выбирают команды под активную
оболочку. Не заменяйте привычные клавиши отдельным набором: изменяйте оба
маршрута через `shellActions`. Caelestia использует свой launcher, OSD,
уведомления, wallpaper и lock; DMS сохраняет собственные сервисы. Общими
остаются Hyprland, PipeWire, portal и пользовательские приложения.
Caelestia использует cliphist, а DMS — собственную историю буфера. Idle timeout
намеренно пустой; не включайте автоматическую блокировку как побочный эффект
смены shell.

Экран входа — системный `core/sddm.nix`; тема в `core/sddm-theme/` использует
системный Stylix. Для безопасного отката на Ly замените import `core/sddm.nix`
на `core/ly.nix` в `profiles/workstation.nix`, соберите конфигурацию и только
затем применяйте её в согласованное владельцем окно. Не запускайте два display
manager и не перезапускайте SDDM в работающей сессии.

Проверяйте выбор shell и SDDM evaluation до сборки:

```sh
nix eval --raw --no-update-lock-file \
  .#nixosConfigurations.desktop.config.services.displayManager.sddm.theme
nix build --no-link --no-update-lock-file .#checks.x86_64-linux.configurations
./scripts/check.sh all
```

Evaluation и сборка не доказывают запуск графического входа, lock, suspend,
screen sharing или работу панели на реальных мониторах.

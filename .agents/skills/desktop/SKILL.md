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

## Выход и диагностика сессии

В сессии UWSM выход должен останавливать графические units через `uwsm stop`.
Общая команда для меню Caelestia и сочетаний выхода задана в
`home/zerokqx/hyprland/binds.nix`: она сверяет сигнатуру экземпляра и не выбирает запасной
выход при ошибках чтения systemd. Её маршруты проверяет
`nix build --no-link --no-update-lock-file .#checks.x86_64-linux.desktop-shells` на заглушках.
Прямой `login1.Session.Terminate` завершает также `sddm-helper` внутри login
scope; после такого выхода SDDM может не вернуть greeter. Не заменяйте выход
на `terminate-user`, `pkill` или перезапуск display manager.

Сначала выберите нужную загрузку через `journalctl --list-boots`, затем
сопоставьте время действия, ID сессии и PID помощника SDDM:

```sh
loginctl list-sessions
systemctl --user --failed
systemctl --user status 'wayland-wm@*.service'
journalctl -b BOOT_ID -o short-monotonic -u display-manager -u systemd-logind
journalctl -b BOOT_ID -o short-monotonic -u session-N.scope
journalctl --user -b BOOT_ID -o short-monotonic
```

`BOOT_ID` и `N` заменяйте фактическими значениями. Отличайте остановку
compositor от возврата greeter и от полного зависания машины. Проверка команды
на подставных исполнителях не подтверждает реальный Logout. Интерактивный
выход завершает приложения и требует отдельного разрешения.

## Раскладка и виджеты

Настройки Caelestia находятся в `desktop.nix`: `utilities.toasts.kbLayoutChanged`
отвечает только за всплывающую подсказку раскладки. `bar.statusIcons` — массив
объектов `{ id, enabled }`, а не объект с полем `values`; переопределение массива
должно сохранять остальные нужные индикаторы. Встроенный `kbLayout` получает
`Hypr.kbLayout` и выводит короткие XKB-коды, например `us`/`ru`.

Состояние берётся из Hyprland `j/devices` при запуске и по событию `activelayout`,
для основной клавиатуры. Проверяйте `hyprctl -j devices`, особенно при разных
раскладках устройств. Не вычисляйте состояние из последнего keybinding.
В закреплённой версии отключение клавиатуры само по себе может не отправить
`activelayout`: обновление придёт при следующем событии раскладки или запуске
оболочки. Не скрывайте это ограничение тестом одной клавиатуры.

Перед созданием QML-виджета проверьте встроенный компонент и настройки
закреплённого input. Для индикатора раскладки отдельный daemon, polling и патч
пакета не нужны. Пользовательский компонент оправдан только отсутствующей
функцией; подключение и тест его состояния должны оставаться явными.

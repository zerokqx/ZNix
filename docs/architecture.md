# Архитектура ZNix

ZNix использует Flakes, `flake-parts`, NixOS modules и встроенный Home Manager. Версии задаёт
`flake.lock`; рефакторинг не обновляет версии используемых зависимостей без
отдельного решения. Архитектура рассчитана на
явное подключение возможностей через стандартные `imports`, без собственного
языка ролей и автоматического обнаружения каталогов.

## Решение и границы миграции

В первой итерации исходный checkpoint — `faead27`. В `20c0da4` исправлены ссылки на перемещённый
Codex-модуль и удалённые пользователем файлы OBS/OpenCode. Этот исправленный
коммит служил базой первого сравнения; исходный checkpoint мог не проходить evaluation.
База второй итерации — `4083c93`, после удаления Rust-меню. Она проходит
evaluation и проверки; работа V2 ведётся в `refactor/nixos-architecture-v2`.

- `flake.nix` — короткая точка входа `flake-parts`. Обычные imports подключают
  Home Manager, `hosts/`, `flake/nixvim.nix` и `flake/quality.nix`.
- `hosts/default.nix` — явный top-level реестр NixOS и standalone Home Manager.
  Он прямо вызывает `nixpkgs.lib.nixosSystem`; каталог с `default.nix` сам по
  себе публичный output не создаёт.
- `hosts/<name>/default.nix` — обычный NixOS-модуль с полным видимым списком
  базы, профилей и hardware. Аппаратные настройки, мониторы, swap и настройки
  конкретной машины остаются здесь.
- `flake/nixvim.nix` и `flake/quality.nix` содержат system-dependent outputs:
  packages, apps, devShell, checks и formatter. `nixosConfigurations` остаются
  top-level. `flake.modules` не используется: для трёх локальных хостов обычные
  пути imports читаются проще, чем отдельный registry.
- `lib/` содержит только общий список внешних Home Manager modules и единую
  политику пакетов.
- `configuration.nix` отвечает за базовую композицию системы. `profiles/`
  собирает рабочее место, разработку и personal (пользователи, VPN и HM).
  `workstation` и `development` подключаются независимо и остаются обычными
  NixOS-модулями по путям.
- `core/` и `configs/` сохраняют действующие предметные модули. Перемещение всех
  файлов в новый каталог `modules/` не решает самостоятельной задачи.
- `home/zerokqx/` и `home/noop/` сохраняют пользовательские настройки.
  Встроенный `noop` исторически объединяет оба профиля, standalone `noop` —
  только свой. В `hosts/noop/default.nix` локальное определение HM помещено
  в обычный inline import после `personal.nix`: порядок слияния списков
  совпадает с исходной конфигурацией.
- `.agents/skills/` — единственный источник проектных skills. `AGENTS.md`
  служит короткой точкой входа; установка не меняет глобальные настройки агента.

## Сохраняемые контракты

| Output                        | Системное имя  | Архитектура    |
| ----------------------------- | -------------- | -------------- |
| `nixosConfigurations.desktop` | `nixos-pc`     | `x86_64-linux` |
| `nixosConfigurations.laptop`  | `nixos-laptop` | `x86_64-linux` |
| `nixosConfigurations.noop`    | `nixos`        | `x86_64-linux` |

Standalone Home Manager: `zerokqx`, `noop`, алиас `zerok` → `zerokqx`.
Пакеты и приложения: `nixvim`, `default` → `nixvim`.
Сохраняются `stateVersion`, загрузчик, диски, шифрование, доступ SSH,
сетевые настройки, пользовательские пакеты и действующие службы.

## Правила расширения

Новая машина получает аппаратный файл и обычный модуль в `hosts/<name>/`, где
явно подключаются база и нужные профили. Затем в `hosts/default.nix` добавляется
прямой вызов `nixpkgs.lib.nixosSystem`. Новый standalone Home Manager
регистрируется там же через локальный `mkHome`.
Имя output и `networking.hostName` могут различаться. Не копируйте UUID, resume
offset и мониторы другой машины.

```nix
new-host = inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [ ./new-host ];
};
```

В `hosts/new-host/default.nix` добавьте `../../configuration.nix`, нужные
`profiles/*.nix` и hardware-модуль в точном порядке. Hardware-конфигурация
задаёт `nixpkgs.hostPlatform`; проверка контрактов следит за архитектурой
трёх текущих хостов. Добавьте новый хост и ожидаемые настройки в
`tests/configurations.nix`; `check.sh eval` автоматически перечислит все outputs.
Локальный `mkHome module` добавляет общую
политику пакетов и внешние Home Manager-модули; он не создаёт новый framework.

Для другого пользователя или серверного окружения выберите собственный обычный
модуль пользователей вместо `profiles/personal.nix`; он включает персональный
набор пользователя `zerok`. Базовая конфигурация сама не выбирает пользователя,
VPN или графическое окружение.

Новый профиль нужен при повторном использовании связанного набора возможностей.
Одиночную настройку добавляйте в существующий профиль или модуль хоста.
Используйте `lib.mkDefault`, `lib.mkIf` и `lib.mkForce` непосредственно; не
создавайте обёрток над стандартными примитивами NixOS.

Новая CPU-архитектура требует проверки доступности всех выбранных пакетов
и flakes. Наличие параметра `system` не доказывает поддержку ARM существующим
рабочим окружением. Не включайте desktop-профиль в сервер без явного решения.

## Порядок проверки

Проверка исходных файлов и формата → evaluation каждого output → проверки
контрактов → dry-build → сборка выбранных closures → отдельное разрешение
на активацию. Успешная evaluation не подтверждает загрузку или работу устройств.
Подробные команды и доставка пакетов описаны в [operations.md](operations.md),
результаты V2 — в [architecture-v2-report.md](architecture-v2-report.md),
история первой итерации — в [refactoring-report.md](refactoring-report.md).

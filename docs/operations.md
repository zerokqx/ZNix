# Проверка, пакеты и deployment

Команды выполняются из корня ZNix. Для воспроизводимых проверок используется
`nix develop`: инструменты берутся из основного nixpkgs в `flake.lock`.
Существующий `devenv` сохранён, но имеет собственный `devenv.lock`.

## Проверка без применения

```sh
nix develop
./scripts/check.sh all
# Для всей серии коммитов укажите её базу:
./scripts/check.sh all --base 20c0da4
nix flake check --no-build --no-update-lock-file
nix flake check --no-update-lock-file
```

`check.sh` разделяет `syntax`, `static` и `eval`. Форматирование проверяется
для изменённых Nix-файлов относительно `--base` (по умолчанию HEAD), включая
новые файлы. Это позволяет не переформатировать чужие старые модули при
маленьком изменении. Проверяйте полный диапазон изменений перед merge.

Новые Nix-модули должны быть добавлены в индекс **точным списком** после review:
Git flakes не видят untracked-файлы. Команды проверки и пересборки индекс не
меняют. Не обходите это через `git add .`, `git add -A` или импорт всего рабочего
каталога как `path:`: так в store могут попасть локальные приватные файлы.

```sh
nix eval --json .#nixosConfigurations --apply builtins.attrNames --no-update-lock-file
nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath --no-update-lock-file
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --dry-run --no-link --no-update-lock-file
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --out-link result-desktop --no-update-lock-file
nix path-info --closure-size --human-readable ./result-desktop
nix store diff-closures /run/current-system ./result-desktop
```

Путь `result-desktop` — GC root, пока ссылка существует. Не удаляйте её между
сборкой и согласованным применением, если closure должен оставаться доступным.
`nix build --no-link` удобен для проверок, но не удерживает результат от GC.
Dry-build сообщает план загрузок и сборок, а не доказывает их успешность.
`nix flake check --no-build` выполняет evaluation; без этого флага запускаются
небольшие объявленные checks, но не сборки всех ОС целиком.

`./scripts/rebuild.sh build desktop` собирает систему. Без имени хоста скрипт
ищет единственное совпадение текущего hostname с вычисленной конфигурацией.
Это учитывает разницу `desktop` ↔ `nixos-pc`, `laptop` ↔ `nixos-laptop` и
`noop` ↔ `nixos`. Незнакомый или неоднозначный hostname требует явного выбора.

## Жизненный цикл пакета

1. `flake.lock` выбирает точные источники; получение flake inputs может идти
   уже во время evaluation. Хост, его `system` и модули задают package set.
2. Evaluation вычисляет derivations и пути результатов. Это ещё не компиляция.
3. Nix повторно использует уже имеющиеся store paths и запрашивает substitutes
   для отсутствующих результатов у настроенных кешей.
4. При найденном и доверенном substitute Nix скачивает готовый путь, проверяя
   подпись и хеш. При промахе получает исходники и build dependencies, затем
   собирает локально или на отдельно настроенном builder.
5. Для удалённой машины копируется замыкание зависимостей (closure). Уже
   существующие там пути повторно передавать не требуется; кеши на получателе
   могут заменить передачу части данных с рабочей станции.
6. Только activation переключает системное поколение и службы. Наличие closure
   в store само по себе конфигурацию не применяет.

Одинаковые пути разделяются между профилями **одного** store. У разных машин
отдельные stores: локальная оптимизация через hard links не объединяет их по сети.
Общая версия lock и отсутствие ненужных overrides повышают возможность повторного
использования готовых путей; реальный cache hit подтверждается планом/логом сборки.

## Политика получения пакетов

Системные `nix.settings` собраны в `core/nixpkgs.nix`. Сохраняются ранее
настроенные NixOS, Hyprland и ryoppippi caches и соответствующие ключи.
Удалены общий сайт `https://cachix.org` (не binary cache) и неиспользуемый,
неподтверждённый ключ Codex без соответствующего substituter. Новые доверенные
кеши и пользователи не добавлены. Проверка подписи не отключается.

`lib/` задаёт общую политику `allowUnfree` и существующих исключений insecure
packages. Эти исключения сохранены ради совместимости, а не признаны безопасными.
`nix-claude-code` overlay применяется в NixOS; standalone Home Manager сохраняет
свою исходную композицию пакетов. Встроенный HM использует `useGlobalPkgs`.

В lock есть несколько nixpkgs revisions, поскольку сторонним inputs нужны свои
версии. Не переводите все inputs на `follows = "nixpkgs"` без отдельной проверки
совместимости: уменьшение числа узлов lock не гарантирует ускорения и может
сломать Hyprland/Nixvim. Обновление lock — самостоятельное изменение.

Частный override Widevine в `home/zerokqx/chromium.nix` фиксирует URL и хеш.
Из самого наличия override нельзя заключить, что весь Chromium компилируется
заново: проверяйте фактический dry-build.

Flatpak-приложения, расширения Chromium и MCP-пакеты с `@latest` имеют отдельный
жизненный цикл. Они не становятся полностью воспроизводимыми от одного
`flake.lock`; это явно оставшаяся граница воспроизводимости.

## Выбор места сборки

| Сценарий | Практика |
| --- | --- |
| Текущая рабочая станция | Сборка локально с кешами; сначала dry-build |
| Laptop той же архитектуры | Локально при достаточных ресурсах; либо подготовка closure на рабочей станции |
| Удалённый сервер | Отдельный зарегистрированный профиль без ненужного GUI; build локально, target удалённо |
| Слабая машина | Подготовить closure на совместимой рабочей станции и передать недостающие пути |
| Другая CPU-архитектура | Native builder этой архитектуры либо отдельно проверенная эмуляция/cross compilation |

Сейчас все реальные хосты — `x86_64-linux`; сервер и ARM — сценарии расширения,
а не проверенные или автоматически созданные машины. Удалённые builders не
настроены: адреса, SSH-ключи и доверие нельзя выдумать из имён хостов.
`builders-use-substitutes = true` разрешает настроенным builders использовать
их кеши, но не создаёт builders само по себе.

Для уже настроенного SSH-доступа команда ниже только передаёт построенную систему:

```sh
nix copy --substitute-on-destination --to ssh://user@target ./result-desktop
```

`user@target` — заменяемый пример, не адрес из реестра. За разными SSH identities
стоят разные права; не используйте `--no-check-sigs` и не добавляйте пользователя
в `trusted-users` ради обхода ошибки. Нестандартные локальные outputs могут
потребовать отдельно согласованного доверия/подписи на принимающей стороне.

## Применение и восстановление

Следующие команды меняют работающую систему и запускаются только после явного
разрешения владельца. `test` тоже выполняет activation, хотя не делает поколение
загрузочным по умолчанию. Перед удалённым применением сохраните второе SSH-соединение
и доступ к консоли/предыдущему загрузочному поколению.

```sh
# Применить именно проверенный closure (поддерживается местным nixos-rebuild):
sudo nixos-rebuild test --store-path "$(readlink -f result-desktop)"
sudo nixos-rebuild switch --store-path "$(readlink -f result-desktop)"

# Построить локально и применить на другом хосте:
nixos-rebuild switch --flake .#laptop --target-host user@target --sudo --use-substitutes --no-update-lock-file

# Построить на отдельной машине, применить на целевой:
nixos-rebuild switch --flake .#laptop --build-host user@builder --target-host user@target --sudo --use-substitutes --no-update-lock-file

# Вернуть предыдущее доступное системное поколение:
sudo nixos-rebuild switch --rollback
```

`--build-host` задаёт место сборки, `--target-host` — место применения.
Без `--target-host` результат удалённой сборки вернётся на локальную машину.
Флаги сверены с установленным `nixos-rebuild` NixOS 26.05: он поддерживает `--sudo`;
после обновлений проверяйте `nixos-rebuild --help`, поскольку интерфейс меняется.

Для отката при незагружающейся системе выберите предыдущее поколение в загрузчике.
Rollback системы не откатывает содержимое баз данных, домашнего каталога и другие
изменяемые данные. Существующий weekly GC удаляет поколения старше 7 дней;
загрузчик хранит до 10 записей, но это не гарантия наличия всех старых closures.
Не запускайте GC, удаление поколений или очистку резервных копий в рамках проверки.

## Измерения

Замеряйте отдельно прогретую evaluation (`nix eval ...drvPath`), fetching,
компиляцию, copy, activation и runtime. Сравнивайте один lock, одинаковые флаги,
одну машину и одинаковый атрибут. Первый запуск может скачать inputs.
Не сравнивайте его с прогретым последующим запуском как выигрыш рефакторинга.

Для boot/runtime доступны `systemd-analyze time`, `systemd-analyze critical-chain`
и `systemctl --failed`. Сокращение времени загрузки можно подтвердить только после
разрешённой активации/перезагрузки. Не отключайте wait-online, Docker или VPN
по одному списку `blame`: сначала выясните, кто зависит от их готовности.

## Первичные источники

- [Nix copy: closure и substitutes на получателе](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-copy).
- [Nix settings: substituters, builders, доверие и GC](https://nix.dev/manual/nix/2.34/command-ref/conf-file.html).
- [Официальная инструкция по distributed builds](https://nix.dev/tutorials/nixos/distributed-builds-setup.html).
- [Codex: обнаружение проектных skills](https://learn.chatgpt.com/docs/build-skills).
- [Claude Code: расположение skills](https://code.claude.com/docs/en/skills).

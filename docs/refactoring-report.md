# Отчёт о рефакторинге ZNix

Дата: 12 ноября 2026. Ветка: `refactor/nixos-agent-driven-architecture`.
Исходная пользовательская работа сохранена в `faead27`; восстановленная база
сравнения — `20c0da4`. Lock-файлы и версии пакетов не обновлялись.

## Architecture Before / After

Раньше каталоги хостов и Home Manager автоматически становились flake outputs.
Каждый хост повторял `nixosSystem`, а общая конфигурация безусловно включала
пользователей, графическое окружение, разработку и VPN. Списки внешних HM-модулей
и политика пакетов повторялись в двух местах.

Теперь `hosts/default.nix` явно регистрирует системы через `mkHost` и дома через
`mkHome`. Модули хостов содержат аппаратные и машинные настройки. Обычные профили
`workstation`, `development` и `personal` задают состав возможностей. База не
выбирает персональный HM-профиль, VPN или графические службы; даже графические
пакеты polkit/xdg перенесены в workstation. Общее осталось в маленьком `lib/`.

Публичные outputs сохранены: NixOS `desktop`, `laptop`, `noop`; Home Manager
`zerokqx`, `noop`, алиас `zerok`; пакеты/приложения `nixvim`, `menu`, `default`.
Встроенный `noop` явно сохраняет историческую композицию `zerokqx` + `noop`,
а standalone `noop` — только свой модуль. Собственный framework ролей не создан.

## Problems Discovered

| Проблема | Результат |
| --- | --- |
| Ссылка на отсутствующий `codex.nix` и неверные пути внутри перенесённого Codex-модуля | Исправлены в отдельном коммите до архитектурной миграции |
| Ссылки на уже удалённые пользователем OBS/OpenCode-файлы | Удалены неработающие подключения, сами удаления сохранены |
| В `home/noop` задана несуществующая опция `znix.monitors` | Удалено пустое неработающее присваивание; evaluation восстановлена |
| Неявное обнаружение новых outputs, повторение constructors/HM imports/package policy | Явный реестр и общая библиотека |
| `system` из legacy `nixosSystem` мог молча уступить hardware `hostPlatform` | `mkHost` проверяет совпадение и сообщает оба значения; отрицательный тест |
| `git add .` / `git add -A` перед сборкой включали посторонние файлы | Rebuild/validation не меняют индекс; установщик добавляет только четыре перечисленных файла после согласия |
| Generic rebuild путал `desktop` с реальным hostname `nixos-pc` | Поиск по вычисленному hostname; неизвестное/неоднозначное имя останавливает команду |
| `devenv menu` запускал удалённую версию вместо текущего checkout | Запускается локальный `.#menu` |
| Меню автоматически доверяло CWD `config.json` с исполняемыми действиями | По умолчанию embedded config; внешний файл только через явный `--config PATH` |
| Старый установщик полагался на автодискавери и мог перезаписывать home/config | Явная регистрация, проверка имён/коллизий/платформы, эксклюзивная блокировка реестра, откат своих незавершённых записей |
| Общий `https://cachix.org` не является binary cache; лишний ключ Codex не имел соответствующего substituter | Удалены из декларативных настроек; новые доверенные сущности не добавлялись |
| Сборка меню зависела от всей папки Rust, включая devenv | Ограниченный fileset: Cargo.toml, Cargo.lock, src и config.json |
| Не было проектной системы skills и воспроизводимых checks | Семь skills, symlink installer, стандартные flake checks и validation shell |

Аудит также выявил оставшиеся проблемы, не скрытые исправлениями: слабые
начальные пароли привилегированных пользователей с password SSH, постоянную
тестовую учётную запись на физических хостах, plaintext Git credential helper,
широкие права Docker/Nix, insecure package exceptions, динамические MCP-пакеты,
Home Manager/Stylix warning и аппаратные настройки, общие для рабочих мест.
Их границы и причины сохранения перечислены ниже.

## Performance Improvements

- Исправлен список substituters. Три сохранённых адреса вернули корректный
  `nix-cache-info`: cache.nixos.org, hyprland.cachix.org, ryoppippi.cachix.org.
  Проверка подписей и прежние ключи сохраняются. Работающий Nix daemon ещё
  использует прежнюю системную конфигурацию: её активация не выполнялась.
- Проверено инвариантное поведение сборки меню: добавление README/devenv в его
  папку не меняет `drvPath`; изменение `config.json` меняет. Это конкретное
  устранение лишних пересборок, а не предположение по количеству строк.
- Состав `environment.systemPackages` по точным отсортированным `outPath`
  сохранён: desktop 197, laptop 182, noop 180 записей. Уменьшение closure путём
  удаления пользовательских приложений не выполнялось.
- На прогретом локальном store dry-build desktop требовал 128 derivations,
  3 недостающих пути (2,6 MiB загрузки / 13,7 MiB unpacked). Общая сборка трёх
  хостов потребовала 274 derivations и 11 путей (15,3 MiB / 28,3 MiB).
  Это состояние данной машины, не обещание для чистого store и не cache-hit rate.

Размер построенных closures: desktop **41,922 GiB**, laptop **39,724 GiB**,
noop **39,709 GiB**. Они содержат общие store paths, поэтому эти размеры нельзя
складывать как расход диска. Измерение: `nix path-info --json --closure-size`.
Для сравнения отдельно построен desktop на восстановленной базе `20c0da4`:
45 013 707 096 bytes до, 45 013 707 008 bytes после (разница −88 bytes).
Практически размер не изменился; уменьшение большого desktop closure не заявляется.

Evaluation desktop `system.build.toplevel.drvPath`, Nix 2.34.7, прогретые inputs,
`--offline --option eval-cache false`, поочерёдно три запуска до/после без
параллельных сборок:

| Версия | Запуск 1 | Запуск 2 | Запуск 3 | Медиана |
| --- | --- | --- | --- | --- |
| До (`20c0da4`) | 28,689 s | 28,820 s | 29,522 s | 28,820 s |
| После | 29,034 s | 29,338 s | 28,784 s | 29,034 s |

Разница медиан около +0,7%; на этих трёх измерениях ускорение не подтверждено.
Первоначальные запуски с fetching inputs и параллельными проверками исключены
из сравнения. Ускорение boot, activation, удалённого копирования и общий
cache-hit rate не заявляются.

Runtime-снимок работающей машины: 66,142 s до graphical.target от старта firmware;
NetworkManager-wait-online 13,014 s и Docker 14,707 s в critical chain. Failed
units не было. Службы не отключались, до/после reboot не сравнивался: перезагрузка
не разрешалась. Дедупликация store, GC, max-jobs и cores оставлены прежними.

## Host & Package Management

Архитектура и профили выбираются явно в реестре. `mkHost` предоставляет fallback
платформы и останавливает evaluation при несовпадении с hardware-модулем.
Пользователь, сервисы, пакеты и сеть задаются стандартными NixOS-модулями.

Rust-установщик поддерживает новую x86_64-машину, не подменяет существующие
каталоги, регистрирует host и home, сохраняет посторонние изменения. Совмещённая
операция staging/build/switch предлагается только для первоначально чистого
checkout, требует явного opt-in и повторной проверки его состояния.
При обычной работе generic `rebuild` теперь означает build; именованные
`rebuild-desktop/laptop/noop` сохраняют прежнюю activation-семантику.

Пакетный путь: locked inputs → evaluation → local store/substituters → build
misses → copy отсутствующих closure paths → отдельно разрешённая activation.
Подробно разделены локальная сборка, `--build-host`, `--target-host`,
`nix copy --substitute-on-destination`, слабая машина и другая CPU-архитектура
в [operations.md](operations.md). Не выдуманы адреса builders, SSH identities,
новые trusted users или собственный cache. Реальные remote/ARM deployments
не проводились; локальные stores разных машин не объединяются автоматически.

## Helpers

- `lib/default.nix`: `mkHost { system; modules; }`, `mkHome { system; module; }`.
  Только общая композиция и контракт платформы, без framework ролей.
- `lib/home-modules.nix`: один список внешних модулей Stylix, DMS и Nixvim.
- `lib/package-policy.nix`: общие существующие allowUnfree/insecure exceptions.
- `pkgs/znix-menu.nix`: обычный `callPackage` с ограниченным fileset.

Не создавались аналоги `mkIf`, `mkMerge`, `mkOption` и других примитивов nixpkgs.

## Agent-Driven Development

`AGENTS.md` даёт карту и границы действий, затем направляет в конкретный skill
и документацию. Исходный код остаётся обычным NixOS-проектом. `CLAUDE.md`
подключает `AGENTS.md`, не дублируя его. Валидация не запускает activation.

Работа распределялась между read-only аудиторами структуры/операций,
архитектурным исполнителем, исполнителем workflows, исполнителем skills и
отдельным security-аудитором. Основные изменения прошли независимое ревью;
оно дополнительно выявило конфликт платформы и гонку регистрации хостов.
Результаты агентов проверены реальными Nix evaluations, сборками и тестами.

## Skills

В `.agents/skills/`: `install`, `architecture`, `hosts`, `packages`, `validation`,
`deployment`, `refactoring`. В каждом есть YAML frontmatter, условия применения,
конкретный workflow и проверки; общие подробности находятся в docs.

`install` относится к агентным skills, а не установке ОС. Агент определяет среду
по контексту своей сессии и передаёт `--environment`. Codex нативно читает
`.agents/skills`, поэтому команда только проверяет наличие. Claude получает
относительные ссылки в `.claude/skills`; для других инструментов возможен явно
выбранный repo-local target. Не используются копии или эвристика по чужим
конфигурационным папкам. Конфликты, dangling/cyclic links и выход за репозиторий
останавливают установку до записи ссылок. Глобальные настройки не меняются.

Установка Codex и двойная установка Claude проверены в текущем checkout;
переносимость ссылок и конфликтные сценарии — в изолированных тестовых каталогах.
Фактический интерфейс обнаружения skills в запущенном Claude Code не тестировался.

## Validation

| Проверка | Результат |
| --- | --- |
| `./scripts/check.sh all --base 20c0da4` | Пройдены syntax, формат изменённых Nix-файлов, ShellCheck, 19 Python-тестов, evaluation 3 NixOS + 3 HM outputs |
| `nix flake check --no-build --no-update-lock-file` | Пройдена evaluation flake outputs |
| `nix flake check --no-update-lock-file` | Собраны configurations, workflow и menu checks |
| `cargo test --locked` | 6 Rust-тестов: конфиги меню, имена/регистрация хостов, сохранение файлов и блокировка записи |
| `devenv shell -- rebuild --help` | Проверена интеграция wrapper с DEVENV_ROOT |
| `devenv shell -- flake-check static --base 20c0da4` | Пройдены форматирование, ShellCheck и Python-тесты |
| `quick_validate.py` для 7 skills с закреплённым Python/PyYAML | Все пройдены |
| Точные системные package outPaths до/после переноса профилей | Совпадают для всех трёх хостов |
| Boot/network/disks/swap/SSH/Nix policy и выбранные service settings против `20c0da4` | Совпадают для трёх хостов, кроме намеренно удалённых cache entries |
| Выбранные HM поля desktop/laptop и standalone zerok/zerokqx | Совпадают; исходный noop был невалиден |
| `nix build` системных toplevel для desktop, laptop и noop | Все три построены |
| Desktop toplevel на базе `20c0da4` | Построен отдельно для сравнения размера closure |
| `git diff --check` | Пройден |
| Activation, reboot, VM, remote deployment, проверка устройств | Не выполнялись |

Полные системные сборки выполнены одной командой:

```sh
nix build .#nixosConfigurations.desktop.config.system.build.toplevel \
  .#nixosConfigurations.laptop.config.system.build.toplevel \
  .#nixosConfigurations.noop.config.system.build.toplevel \
  --no-link --print-out-paths --no-update-lock-file \
  --option substituters 'https://cache.nixos.org https://hyprland.cachix.org https://ryoppippi.cachix.org'
```

CLI substituters использованы, чтобы не менять работающий демон и не обращаться
к старому ошибочному адресу. Standalone HM outputs проверены evaluation;
отдельная активация поверх системного HM не выполнялась. Исходные попытки
Cargo без C compiler и skill validator без PyYAML завершились ошибками окружения;
после выбора доступных закреплённых инструментов проверки прошли.

## Risks & Limitations

- Слабые начальные пароли `zerok` и `nixosvmtest`, парольный SSH и постоянный
  тестовый пользователь сохраняются. Это риск нового развёртывания; фактические
  текущие пароли не проверялись. Изменение доступа требует согласования и
  подтверждённого резервного входа. Значения паролей в отчёт не включены.
- `credential.helper = store` остаётся потенциальным plaintext-хранилищем
  HTTPS-секретов. Не проверялось наличие сохранённых credentials и не изменялись
  пользовательские способы авторизации.
- Прежние Docker/root-equivalent Nix privileges, trusted bridge interfaces,
  reverse-path policy, Steam/UDP-порты и root QEMU не менялись. Их назначение
  нужно оценивать с учётом реальной локальной инфраструктуры.
- В `flake.lock` семь отдельных nixpkgs revisions; они не объединялись
  автоматически из-за риска несовместимости transitive inputs.
- Неподдерживаемые пакеты в `permittedInsecurePackages`, Flatpak/Chromium extensions
  и MCP `@latest` остаются отдельными рисками обновления и воспроизводимости.
- Существующее предупреждение Home Manager при `useGlobalPkgs` исходит из
  upstream Stylix overlays `nixos-icons` и `gtksourceview`. Оно также возникает
  на базе до рефакторинга. Перед обновлением HM нужна отдельная совместимая
  миграция Stylix, а не отключение предупреждения вслепую.
- `apps.*.meta.description` отсутствует, о чём Nix выдаёт неблокирующее
  предупреждение. В параллельных проверках встречались SQLite busy; итоговые
  проверки завершились успешно. Финальные benchmark runs выполнялись отдельно.
- Общие AMD/Intel graphics настройки, Zen kernel и gamescope `DP-1` сохранены
  ради совместимости. Нет утверждения об их оптимальности для laptop/server.
  Неиспользуемые `ollama.nix`, `zapret.nix` и старые переводы не активировались.
- Не выполнялись вход на реальные устройства, VM boot, remote copy, смена
  поколений и reboot. Успешная сборка не доказывает фактическую загрузку.
- GC остаётся weekly с удалением поколений старше 7 дней. Построенные через
  `--no-link` результаты не закреплены GC root: перед deployment создайте
  удерживающую ссылку, как описано в operations.
- Security-аудит статический и частичный, привязан к `faead27`; история,
  работающие секреты/службы и все внешние зависимости не сканировались.
  Из четырёх reportable findings исправлены ambient config меню и массовый
  staging; начальные пароли/SSH и plaintext credential helper остаются.

Подробные локальные артефакты вне репозитория:
[исходный security-аудит](/home/zerok/.codex/state/plugins/codex-security/scans/ZNix/faead2790034efe11c86fb012a4573c148fbf6b2_20261112T184036Z_0e9x8res/report.md),
[проверка исправления меню](/home/zerok/.codex/state/plugins/codex-security/scans/ZNix/artifacts-133828f00ee831a24f51d842334f46616a58c26298ac59f08aaa0945b4298e53/report_validation.md).
Эти ссылки привязаны к данной машине; существенные результаты сохранены выше.

## Git Summary

Ветка `refactor/nixos-agent-driven-architecture`; push и activation не выполнялись.

- `faead27` — checkpoint пользовательских изменений на исходной main.
- `20c0da4` — восстановление перемещённых/удалённых Home Manager references.
- `2bc4835` — зафиксированные решения и границы миграции.
- `cc7271f` — явный реестр, библиотека, профили и checks.
- `545dfb4` — проектные skills, installer и документация.
- `db3ec23` — проверка платформы, разделение пакетов профилей.
- `376f1f5` — безопасные workflows, новый установщик и явный конфиг меню.

Этот отчёт и уточнения документации сохраняются заключительным docs-коммитом;
его идентификатор доступен через `git log -1`. Исходные staged/unstaged patches
и индекс дополнительно сохранены в приватном временном backup-каталоге;
долговременная точка восстановления — checkpoint-коммит.

## Future Recommendations

1. Отдельно согласовать безопасные начальные credentials, перенос тестового
   пользователя только в VM и политику SSH, проверив альтернативный вход.
2. Проверить Stylix/HM upgrade path и заменить устаревающие insecure packages.
3. Уточнить реальные роли laptop/desktop, доступные устройства и назначение
   сетевых сервисов до сокращения closures и фоновых служб.
4. При появлении реального слабого хоста выбрать доверенный builder/cache,
   измерить upload/download и копирование closure на этом соединении.
5. Подключить существующие `nix flake check` к CI, когда определены runner и
   бюджет кеширования; не делать CI способным применять систему автоматически.
6. После отдельно разрешённого deployment проверить загрузку, мониторы, звук,
   VPN, SSH, hibernation и runtime; только тогда сравнивать boot timings.

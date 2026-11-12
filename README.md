# ZNix

Персональная конфигурация NixOS и Home Manager для трёх машин x86_64-linux.
Рабочее окружение: Hyprland, Dank Material Shell, Fish и Nixvim.
Основная версия системы — NixOS 26.05; зависимости закреплены в `flake.lock`.

| Хост flake | Имя системы    | Профили                                                             |
| ---------- | -------------- | ------------------------------------------------------------------- |
| `desktop`  | `nixos-pc`     | workstation + development + personal                                |
| `laptop`   | `nixos-laptop` | workstation + development + personal                                |
| `noop`     | `nixos`        | workstation + development + personal + дополнения Home Manager noop |

`flake.nix` использует flake-parts. Системы и самостоятельные конфигурации
Home Manager явно зарегистрированы в `hosts/default.nix`. Форматирование, среда разработки, VM-тест и проверки определены через
`perSystem` в `flake/`. Отдельных приложений для `nix run` и установщика для
сторонних пользователей нет; Nixvim входит в личную конфигурацию Home Manager.
Каждый хост явно подключает базу, профили и своё оборудование. Общие системные
модули находятся в `core/` и `configs/`, пользовательские настройки — в `home/`,
общие модули Home Manager и политика пакетов — в `lib/`.

## Проверка и сборка

```sh
nix develop -c bash
nix fmt -- flake.nix hosts/default.nix
./scripts/check.sh all
nix flake check --no-build --no-update-lock-file
nix flake check --no-update-lock-file
./scripts/rebuild.sh build desktop
```

Для проверки всей серии изменений укажите `check.sh all --base <коммит>`.
Новые файлы, на которые ссылается flake, добавляйте в Git точными путями после
проверки содержимого. Скрипты пересборки сами ничего не добавляют в индекс.

Общая команда `rebuild` по умолчанию только собирает систему. Команды devenv
`rebuild-desktop`, `rebuild-laptop` и `rebuild-noop` применяют конфигурацию;
варианты `-test` тоже меняют работающую систему. Используйте их осознанно.
Без указания хоста скрипт ищет единственное соответствие текущему имени машины.
Успешная сборка не означает применение конфигурации или проверку оборудования.

## Подключение агентов

Прочитайте [AGENTS.md](AGENTS.md) и
[инструкцию установки skills](.agents/skills/install/SKILL.md), затем выберите среду:

```sh
python3 scripts/install-skills.py --environment codex
python3 scripts/install-skills.py --environment claude
```

Codex читает `.agents/skills` напрямую. Для Claude создаются относительные ссылки
на каждый skill. Повторная установка безопасна и останавливается при конфликте.
Глобальные настройки агентов не меняются.

## Добавление хоста

Создайте модуль в `hosts/<имя>/` с явными imports оборудования, базы и выбранных
профилей. Зарегистрируйте его в `hosts/default.nix` через `nixpkgs.lib.nixosSystem`.
Самостоятельную конфигурацию Home Manager при необходимости добавьте через
локальный `mkHome`. Подробности — в [описании архитектуры](docs/architecture.md).

UUID дисков, параметры возобновления из гибернации и мониторы относятся к
конкретной машине. Для другой архитектуры процессора отдельно проверяйте
совместимость пакетов. Применение конфигурации и разрушительные операции
требуют явного разрешения владельца.

## Документация

- [Архитектура и добавление хостов](docs/architecture.md)
- [Проверки, пакеты, развёртывание и восстановление](docs/operations.md)
- [Отчёт об архитектуре V2 и границы проверок](docs/architecture-v2-report.md)
- [Отчёт о первой итерации — исторический документ](docs/refactoring-report.md)

# ZNix: точка входа для агентов

Персональная NixOS/Home Manager конфигурация. Источник истины — Nix-модули,
явный реестр `hosts/default.nix` и `flake.lock`. Текущие хосты: `desktop`
(`nixos-pc`), `laptop` (`nixos-laptop`), `noop` (`nixos`), все `x86_64-linux`.

## Начало работы и skills

1. Прочитайте `git status --short --branch` и изменения перед правками.
   Сохраняйте чужую работу; добавляйте в индекс только просмотренные пути.
2. Для структуры откройте [docs/architecture.md](docs/architecture.md), для
   команд и доставки пакетов — [docs/operations.md](docs/operations.md).
3. Выберите подходящий `.agents/skills/<name>/SKILL.md`: `architecture`,
   `hosts`, `packages`, `validation`, `deployment` или `refactoring`.
4. Для подключения skills сначала прочитайте
   [.agents/skills/install/SKILL.md](.agents/skills/install/SKILL.md).
   Это bootstrap, доступный до создания ссылок. Среду определяйте по текущей
   сессии агента, а не по наличию чужих конфигурационных каталогов:

   ```sh
   python3 scripts/install-skills.py --environment codex
   python3 scripts/install-skills.py --environment claude
   ```

Codex читает `.agents/skills` напрямую; первая команда проверяет наличие skills.
Claude Code получает относительные ссылки в `.claude/skills`, а `CLAUDE.md`
подключает этот файл. Для другого инструмента нужен явно выбранный repo-local
`--target`. Установщик не перезаписывает конфликты или глобальные настройки.

## Где менять

- `hosts/default.nix`: явная регистрация outputs и выбор `system`/профилей.
  Каталоги сами не регистрируются. Для новой машины добавьте hardware-модуль и
  запись через `mkHost`; для standalone Home Manager — запись через `mkHome`.
- `hosts/<name>/`: hardware, диски, мониторы и настройки конкретной машины.
- `configuration.nix`, `core/`: базовая композиция и системные модули.
- `profiles/`: workstation, development и personal (пользователи, VPN, HM).
- `lib/`: общие конструкторы, внешние HM-модули и политика пакетов.
- `home/`: пользовательские приложения; `configs/`: VPN-модули.
- `scripts/`, `tests/`: воспроизводимые проверки и явные операции.

Используйте обычные NixOS `imports` и стандартные примитивы `nixpkgs.lib`.
Не создавайте framework ролей или абстракцию для одиночной настройки. Общие
helpers размещайте в `lib/`. Обновляйте skill и документацию при изменении
контракта. Встроенный `noop` объединяет два HM-профиля; standalone `noop`
сохраняет свой набор. Не меняйте это случайно.

## Проверка

```sh
nix develop
./scripts/check.sh all --base <база-проверяемой-ветки>
nix flake check --no-build --no-update-lock-file
nix flake check --no-update-lock-file
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --dry-run --no-link --no-update-lock-file
```

Без `--base` формат сравнивается с HEAD. Новые файлы flake сначала добавьте
в Git точными путями, проверив секреты. Evaluation, сборка, activation и проверка
устройств — разные результаты; указывайте, какие фактически подтверждены.

## Границы действий

Без явного разрешения владельца не выполняйте `switch`, `test`, `boot`,
standalone HM activation, удалённое применение, reboot, partitioning, GC или
удаление поколений. Не меняйте критические параметры загрузки, шифрования,
дисков, SSH-доступа и сети без отдельного обоснования и согласования.
Ранее данное разрешение сохраняет силу в пределах выбранной операции и цели.

Не обновляйте `stateVersion` или `flake.lock` как побочный эффект рефакторинга.
Не добавляйте cache keys, trusted users/builders и insecure exceptions без
необходимости. Не отключайте подписи, firewall или sandbox ради ускорения.
Секреты не должны попадать в Git, Nix store и отчёты.

Для самостоятельной маленькой правки сабагент не нужен. При независимых задачах
используйте доступные настроенные роли: `fast_scanner` для ограниченного чтения,
`routine_worker` для простой правки, `terra_worker` для обычной реализации,
`deep_worker` для неоднозначной архитектуры. Назначайте непересекающиеся файлы;
основной агент проверяет результат и не дублирует завершённое исследование.

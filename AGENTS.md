# ZNix: точка входа для агентов

Персональная NixOS/Home Manager конфигурация. Источник истины — Nix-модули,
явный реестр `hosts/default.nix`, модули `flake/` и `flake.lock`. Текущие хосты: `desktop`
(`nixos-pc`), `laptop` (`nixos-laptop`), `noop` (`nixos`), все `x86_64-linux`.

## Начало работы и skills

1. Прочитайте `git status --short --branch` и изменения перед правками.
   Сохраняйте чужую работу; добавляйте в индекс только просмотренные пути.
2. Для структуры откройте [docs/architecture.md](docs/architecture.md), для
   команд и доставки пакетов — [docs/operations.md](docs/operations.md).
3. Выберите подходящий `.agents/skills/<name>/SKILL.md`: `architecture`,
   `desktop`, `desktop-backgrounds`, `stylix`, `hosts`, `packages`, `nixvim`,
   `validation`, `deployment` или `refactoring`.
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

- `flake.nix`: короткая точка входа `flake-parts`; top-level outputs собирают
  `hosts/`, а `flake/quality.nix` задаёт `perSystem` для инструментов проверки.
- `hosts/default.nix`: явная регистрация NixOS и standalone Home Manager outputs.
  Каталоги сами не регистрируются. Для новой машины добавьте прямой
  `nixpkgs.lib.nixosSystem` с модулем хоста; для standalone Home Manager —
  запись через локальный `mkHome`.
- `hosts/<name>/`: полный явный список базы, профилей, hardware, дисков,
  мониторов и настроек конкретной машины.
- `configuration.nix`, `core/`: базовая композиция и системные модули.
- `profiles/`: workstation, development и personal (пользователи, VPN, HM).
- `lib/`: только общие внешние HM-модули и политика пакетов.
- `home/`: пользовательские приложения; `configs/`: VPN-модули.
- `home/zerokqx/nixvim/`: личная конфигурация Nixvim. Перед её изменением
  прочитайте skill `nixvim`; отдельного `nix run` package или установщика нет.
- `home/zerokqx/desktop.nix`: выбор личной shell между Caelestia и DMS;
  перед изменением оболочки, её автозапуска или горячих клавиш прочитайте
  skill `desktop`.
- `home/zerokqx/znix/stylix-celestia.nix`: локальный target Stylix для
  Caelestia; общая палитра для пользовательской сессии и SDDM находится в
  `lib/stylix-theme.nix`. Перед темизацией прочитайте skill `stylix`.
- `scripts/generate-liquid.py`: отдельный GLSL-генератор MP4-фонов;
  используйте `desktop-backgrounds`. Он не изменяет SDDM и требует отдельного
  подтверждения owner перед любой интеграцией результата в экран входа.
- `scripts/`, `tests/`: воспроизводимые проверки и явные операции.

Используйте обычные NixOS `imports` и стандартные примитивы `nixpkgs.lib`.
Не создавайте framework ролей или абстракцию для одиночной настройки. Общие
helpers размещайте в `lib/`. Обновляйте skill и документацию при изменении
контракта. Встроенный `noop` объединяет два HM-профиля; standalone `noop`
сохраняет свой набор. Не меняйте это случайно.

## Проверка

```sh
nix develop -c bash
./scripts/check.sh all --base <база-проверяемой-ветки>
nix fmt -- <изменённые-файлы>
nix flake check --no-build --no-update-lock-file
nix flake check --no-update-lock-file
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --dry-run --no-link --no-update-lock-file
```

`nix fmt` меняет указанные файлы. Без `--base` статическая проверка сравнивается
с HEAD и запускает treefmt на временных копиях изменённых файлов, поэтому не
меняет рабочее дерево или индекс. Новые файлы flake сначала добавьте
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

`git-hooks.nix` не устанавливается автоматически: текущий быстрый gate —
`./scripts/check.sh static`. Не запускайте генераторы hooks, если это меняет
`core.hooksPath` без отдельного решения владельца.

Для самостоятельной маленькой правки сабагент не нужен. При независимых задачах
используйте доступные настроенные роли: `fast_scanner` для ограниченного чтения,
`routine_worker` для простой правки, `terra_worker` для обычной реализации,
`deep_worker` для неоднозначной архитектуры. Назначайте непересекающиеся файлы;
основной агент проверяет результат и не дублирует завершённое исследование.

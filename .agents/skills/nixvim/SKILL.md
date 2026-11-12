---
name: nixvim
description: "Менять или диагностировать личную конфигурацию Nixvim в ZNix: плагины, LSP, клавиши, производительность и проверки."
---

# Nixvim в ZNix

Nixvim — личная функция Home Manager в `home/zerokqx/nixvim/`. Отдельных
`nix run` package, app output и установщика нет. Перед изменением плагина или
клавиши прочитайте модуль и его вызовы:

- `default.nix` включает Nixvim; `config.nix` собирает общий интерфейс,
  Treesitter и диагностику; `languages.nix` содержит LSP, форматтеры и
  языковые инструменты.
- `completion.nix`, `keymaps.nix`, `autocmds.nix`, `mini.nix`, `snacks.nix`,
  `flash.nix` и `opts.nix` отвечают за одноимённое поведение. Imports должны
  оставаться явными.

Используйте закреплённый модуль Nixvim через Home Manager. `plugins.lsp` уже
генерирует нативную конфигурацию LSP Neovim; сохраняйте декларативные настройки
серверов. CSSLS требует собственного `before_init` со snippet capability, хотя
глобальные snippets выключены. Не добавляйте второй completion engine: настроен
Blink.

Перед удалением или заменой плагина найдите его mappings, autocmds, Lua-вызовы
и зависимости пакетов. Сохраняйте привычные клавиши, если задача не требует
их изменить. Предпочитайте нативные возможности Neovim и уже используемые
Snacks/Mini параллельному плагину.

Сначала вычислите derivation, затем при необходимости соберите пакет Home Manager:

```sh
nix eval --raw --no-update-lock-file \
  .#homeConfigurations.zerokqx.config.programs.nixvim.build.package.drvPath
nix build --no-link --print-out-paths --no-update-lock-file \
  .#homeConfigurations.zerokqx.config.programs.nixvim.build.package
```

Вторая команда печатает путь `/nix/store/...-nixvim`; используйте его
`bin/nvim` для проверок. Сборка не активирует пользовательскую конфигурацию.
Не возвращайте standalone outputs без явного запроса.

Для замеров после сборки используйте один и тот же напечатанный путь:

```sh
python3 scripts/benchmark-nixvim.py /nix/store/...-nixvim/bin/nvim \
  /tmp/znix-nixvim/after
```

Скрипт изолирует XDG-state и несколько раз запускает headless и терминальный
Neovim. Его «cold» означает пустое состояние редактора, а не очистку кеша ОС
или Nix. Сравнивайте одинаковые версию бинарника, fixtures и окружение;
отдельно сообщайте startup, runtime и стоимость Nix-сборки.

Проверяйте изменённую функциональность headless-фикстурами в отдельном
каталоге: они не должны использовать пользовательский XDG-state, Wayland,
Hyprland или DBus-сессию. Подставьте путь, напечатанный сборкой:

```sh
ZNIX_NIXVIM_BIN=/nix/store/...-nixvim/bin/nvim
ZNIX_NIXVIM_STATE=$(mktemp -d)
mkdir -p "$ZNIX_NIXVIM_STATE"/{config,data,cache,state,runtime}

for test in tests/nixvim.lua tests/nixvim-runtime.lua tests/nixvim-lsp.lua; do
  env -u HYPRLAND_INSTANCE_SIGNATURE -u DISPLAY -u WAYLAND_DISPLAY \
    -u DBUS_SESSION_BUS_ADDRESS \
    HOME="$ZNIX_NIXVIM_STATE" \
    XDG_CONFIG_HOME="$ZNIX_NIXVIM_STATE/config" \
    XDG_DATA_HOME="$ZNIX_NIXVIM_STATE/data" \
    XDG_CACHE_HOME="$ZNIX_NIXVIM_STATE/cache" \
    XDG_STATE_HOME="$ZNIX_NIXVIM_STATE/state" \
    XDG_RUNTIME_DIR="$ZNIX_NIXVIM_STATE/runtime" \
    "$ZNIX_NIXVIM_BIN" --headless -i NONE -c "luafile $test"
done
```

Перед изменением клавиши проверьте её текущее определение в запущенном Nixvim:
`vim.fn.maparg("<leader>ff", "n", false, true)` показывает структуру mapping,
а `:verbose nmap <leader>ff` — последнее место, которое его задало. Сверяйте
алиасы и режимы, а не только наличие новой записи.

Nixvim и его nixpkgs закреплены в `flake.lock`; не обновляйте их попутно с
настройкой. При отдельном осознанном обновлении выполните
`nix flake lock --update-input nixvim`, просмотрите lock-файл и сравните
сгенерированный Lua старого и нового store-пути:

```sh
"$ZNIX_NIXVIM_BEFORE/bin/nixvim-print-init" > /tmp/nixvim-before.lua
"$ZNIX_NIXVIM_AFTER/bin/nixvim-print-init" > /tmp/nixvim-after.lua
diff -u /tmp/nixvim-before.lua /tmp/nixvim-after.lua
```

Затем повторите сборку, три headless-фикстуры и `./scripts/check.sh all`.
Изменение версии Nixvim и совместимого с ней nixpkgs должно быть отдельным
решением и ревью, без принудительных `follows`.

Не объявляйте интерактивный сценарий проверенным только по headless-тесту.
Выбирайте Treesitter-грамматики явно через
`config.plugins.treesitter.package.builtGrammars`; не включайте все грамматики
по умолчанию.

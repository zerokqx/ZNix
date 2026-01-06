# Установка

1. Уставновить `NixOS`
2. Сделать `nixos-rebuild switch` где надо добавить
   `nix.settings.experimental-features` с `["nix-command" "flakes"]`. Всё это
   проделываеться в `configuration.nix`.
3. После того как в системе станет доступна функция `flakes` (Проверить можно
   введя `nix flake init` это создаст в текущей директории `flake.nix`)
   клонируете этот репозиторий коммандой
   `git clone https://github.com/zerokqx/ZNix`.
4. Затем заходим в склонированый репозиторий и прописываем комманду
   `sudo nixos-rebuild switch --flake .`

---

> [!danger] Не забудте поменять `hardware-configuration.nix` на свой. Он по
> дефолту лежит в `/etc/nixos`

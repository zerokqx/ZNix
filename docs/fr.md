# Documentation ZNix
<div class="lang-switch">
  <a href="../README.md">English</a> |
  <a href="ru.md">Русский</a> |
  <a href="uk.md">Українська</a> |
  <a href="es.md">Español</a> |
  <a href="de.md">Deutsch</a> |
  <a href="fr.md">Français</a> |
  <a href="pt-br.md">Português (BR)</a> |
  <a href="zh-CN.md">中文</a>
</div>

![Bannière](../assets/banner.jpg)

Ensemble de configurations NixOS/home-manager par hôte. Ci-dessous : organisation des fichiers, options personnalisées, avertissement hardware-configuration, et comment réutiliser ou ajouter un hôte.

## Points forts
- SwayFX préconfiguré avec Noctalia Shell (barre/panel, sorties, autostart).
- Neovim via nixvim avec plugins pour LSP, complétion, UI/Treesitter, DAP.
- Thème Stylix avec curseurs/icônes personnalisés et intégration GTK, fzf, lazygit, noctalia.
- Module optionnel SillyTavern + Ollama et module de ports dev pour le LAN.

## Exemples

- `fastfetch` + nixvim : ![Exemple 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia : ![Exemple 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Structure
- `flake.nix` : entrée ; récupère nixpkgs 25.11, home-manager, nixvim, stylix, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop` : points d’entrée nixosSystem ; importent `configuration.nix`, leur `hardware-configuration.nix`, modules hôte (ollama, fprintd/opencode) et HM pour `zerok`.
- `configuration.nix` : base système ; importe `core/` et `configs/`.
- `core/` : modules système (boot, nixpkgs, réseau, audio, graphique, utilisateurs, etc.) + `znix/` pour les options personnalisées.
- `configs/` : tweaks supplémentaires (ex. `throne.nix`, `zapret.nix`).
- `home/` : configuration HM pour `zerok` ; inclut swayfx (`home/sway/`), paquets, thèmes, nixvim (`home/nixvim/`), etc.

## Options personnalisées
- Système :
  - `znix.monitors.*` (`home/znix/monitors.nix`) : modes/positions des écrans et cible de la barre Noctalia.
  - `znix.dev.ports.*` (`core/znix/ports.nix`) : ouvre des ports TCP de dev sur l’interface choisie (`interface`, `tcpPorts`).
  - `znix.ai.sillytavern.*` (`core/znix/silly-tavern.nix`) : active SillyTavern et Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
  - `znix.hardware.fingerprint.goodix.*` (`core/znix/finger-print.nix`) : active le lecteur Goodix (fprintd/TOD).
- Home :
  - `znix.browser.*` (`home/znix/browser.nix`) : options Firefox (profil, extensions, favoris par défaut).
  - `znix.theme.*` (`home/znix/theme.nix`) : polarité du thème, paquet de curseurs, paquet/noms d’icônes pour stylix.

## Avertissement hardware-configuration
- Les fichiers `hosts/*/hardware-configuration.nix` sont propres à la machine ; **remplacez-les** par les vôtres (en général `/etc/nixos/hardware-configuration.nix` après l’installation).
- Évitez de commiter des configs matérielles tierces ; gardez les vôtres localement ou en privé.

## Utiliser un hôte existant
1) Installez NixOS et activez les flakes (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Clonez le dépôt et remplacez `hosts/<target>/hardware-configuration.nix` par le vôtre.
3) Construisez : `sudo nixos-rebuild switch --flake .#desktop` (ou `.#laptop`).
4) Vérif rapide sans switch : `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Ajouter un nouvel hôte
1) Copiez un dossier `hosts/<name>/` existant et placez votre `hardware-configuration.nix`.
2) Dans le nouveau `default.nix`, définissez `system` et activez les modules/overlays requis.
3) Ajustez les spécificités HM (position de la barre noctalia, échelle des polices, layout des écrans, etc.).
4) Construisez : `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` ou `sudo nixos-rebuild switch --flake .#<name>`.

## Notes
- home-manager vit dans les modules NixOS (pas d’output `homeConfigurations` séparé).
- Les nouveaux modules doivent être ajoutés explicitement dans les `default.nix` concernés (pas d’auto-import).

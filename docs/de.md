# ZNix Dokumentation
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

<style>
:root {
  --znix-bg: #1a1b26;
  --znix-accent: #7aa2f7;
  --znix-accent-soft: #7dcfff;
  --znix-border: #3b4261;
}
a {
  color: var(--znix-accent);
  font-weight: 600;
  text-decoration: none;
  border-bottom: 1px solid var(--znix-border);
  padding-bottom: 1px;
  transition: color 0.2s ease, border-color 0.2s ease;
  border-radius: 0;
}
a:hover {
  color: var(--znix-accent-soft);
  border-color: var(--znix-accent-soft);
}
img {
  border-radius: 0;
  border: 1px solid var(--znix-border);
  box-shadow: 0 6px 30px rgba(26, 27, 38, 0.45);
}
.lang-switch a {
  display: inline-block;
  padding: 6px 10px;
  background: var(--znix-bg);
  border: 1px solid var(--znix-border);
  border-radius: 0;
  margin-right: 6px;
}
</style>

![Banner](../assets/banner.jpg)

NixOS/home-manager Konfigurationssatz mit Host-Trennung. Unten: Struktur, eigene Optionen, Hinweis zu hardware-configuration und wie man Hosts nutzt oder hinzufügt.

## Highlights
- SwayFX mit vorkonfiguriertem Noctalia Shell (Panel/Bar, Outputs, Autostart).
- Neovim via nixvim mit Plugins für LSP, Completion, UI/Treesitter, DAP.
- Stylix-Theme mit eigenen Cursor/Icon-Paketen und Integration in GTK, fzf, lazygit, noctalia.
- Flatpak-Integration über nix-flatpak plus HM-verwaltete Pakete/Fonts.
- Optionales SillyTavern + Ollama Modul und dev-Ports-Modul fürs LAN.

## Beispiele

- `fastfetch` + nixvim: ![Beispiel 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Beispiel 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Struktur
- `flake.nix`: Einstieg; zieht nixpkgs 25.11, home-manager, nixvim, stylix, nix-flatpak, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: nixosSystem-Einstiege; importieren `configuration.nix`, eigenes `hardware-configuration.nix`, Host-Module (ollama, fprintd/opencode) und HM für `zerok`.
- `configuration.nix`: Basisstack; importiert `core/` und `configs/`.
- `core/`: System-Module (Boot, nixpkgs, Netzwerk, Audio, Grafik, User etc.) plus `dev/`, `silly-tavern.nix`, `hardware/`.
- `configs/`: Extra Tweaks (z.B. `throne.nix`, `zapret.nix`).
- `home/`: HM-Konfig für `zerok`; beinhaltet swayfx (`home/sway/`), Pakete, Themes, nixvim (`home/nixvim/`) usw.

## Eigene Optionen
- System:
  - `dev.ports.*` (`core/dev/ports.nix`): öffnet Dev-TCP-Ports auf einem Interface (`interface`, `tcpPorts`).
  - `ai.sillytavern.*` (`core/silly-tavern.nix`): schaltet SillyTavern und Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
- Home:
  - `theme.*` (`home/stylix.nix`): Themen-Polarity, Cursor-Paket, Icon-Paket/-Namen für stylix.

## Hinweis zu hardware-configuration
- `hosts/*/hardware-configuration.nix` ist hardware-spezifisch; **ersetzen** mit deiner Datei (typisch `/etc/nixos/hardware-configuration.nix` nach Installation).
- Keine fremden hardware-configs committen; lokal oder privat halten.

## Existierende Hosts nutzen
1) NixOS installieren und flakes aktivieren (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Repo clonen und `hosts/<target>/hardware-configuration.nix` durch deine Datei ersetzen.
3) Bauen: `sudo nixos-rebuild switch --flake .#desktop` (oder `.#laptop`).
4) Schneller Build-Check ohne Switch: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Neuen Host hinzufügen
1) Einen vorhandenen Ordner `hosts/<name>/` kopieren und eigenes `hardware-configuration.nix` ablegen.
2) Im neuen `default.nix` `system` setzen und benötigte Module/Overlays aktivieren.
3) HM-Details anpassen (noctalia Bar-Position, Font-Scale, Display-Layout usw.).
4) Bauen: `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` oder `sudo nixos-rebuild switch --flake .#<name>`.

## Notizen
- home-manager lebt innerhalb der NixOS-Module (kein separates `homeConfigurations` Output).
- Neue Module explizit in die jeweiligen `default.nix` eintragen (kein Auto-Import).

# Documentación de ZNix
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

Conjunto de configuraciones NixOS/home-manager por host. Aquí: qué hay en cada lugar, opciones personalizadas, aviso sobre hardware-configuration y cómo usar o añadir un host.

## Destacados
- SwayFX con Noctalia Shell preconfigurado (panel/barra, salidas, autostart).
- Neovim vía nixvim con plugins para LSP, autocompletado, UI/Treesitter, DAP.
- Tema Stylix con cursores/íconos personalizados e integración en GTK, fzf, lazygit, noctalia.
- Integración Flatpak mediante nix-flatpak más paquetes/fuentes gestionados por home-manager.
- Módulo opcional SillyTavern + Ollama y módulo de puertos dev para LAN.

## Ejemplos

- `fastfetch` + nixvim: ![Ejemplo 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Ejemplo 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Estructura
- `flake.nix`: entrada; obtiene nixpkgs 25.11, home-manager, nixvim, stylix, nix-flatpak, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: puntos nixosSystem; importan `configuration.nix`, su `hardware-configuration.nix`, módulos del host (ollama, fprintd/opencode) y HM para `zerok`.
- `configuration.nix`: base del sistema; importa `core/` y `configs/`.
- `core/`: módulos del sistema (boot, nixpkgs, red, audio, gráficos, usuarios, etc.) más `dev/`, `silly-tavern.nix`, `hardware/`.
- `configs/`: ajustes extra (p. ej., `throne.nix`, `zapret.nix`).
- `home/`: configuración HM para `zerok`; incluye swayfx (`home/sway/`), paquetes, temas, nixvim (`home/nixvim/`), etc.

## Opciones personalizadas
- Sistema:
  - `dev.ports.*` (`core/dev/ports.nix`): abre puertos TCP de desarrollo en una interfaz (`interface`, `tcpPorts`).
  - `ai.sillytavern.*` (`core/silly-tavern.nix`): activa SillyTavern y Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
- Home:
  - `theme.*` (`home/stylix.nix`): polaridad del tema, paquete de cursores, paquete/nombres de íconos para stylix.

## Aviso sobre hardware-configuration
- Los `hosts/*/hardware-configuration.nix` son específicos de la máquina; **cámbialos** por los tuyos (normalmente `/etc/nixos/hardware-configuration.nix` tras la instalación).
- No comitees hardware ajeno; mantenlo local o privado.

## Cómo usar un host existente
1) Instala NixOS y habilita flakes (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Clona el repo y reemplaza `hosts/<target>/hardware-configuration.nix` por el tuyo.
3) Construye: `sudo nixos-rebuild switch --flake .#desktop` (o `.#laptop`).
4) Comprobación rápida sin cambiar: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Cómo añadir un host nuevo
1) Copia un `hosts/<name>/` existente y coloca tu `hardware-configuration.nix`.
2) En el nuevo `default.nix`, ajusta `system` y habilita módulos/overlays necesarios.
3) Ajusta HM (posición de la barra noctalia, escala de fuente, layout de pantallas, etc.).
4) Construye: `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` o `sudo nixos-rebuild switch --flake .#<name>`.

## Notas
- home-manager vive dentro de los módulos de NixOS (no hay output `homeConfigurations` separado).
- Los módulos nuevos deben añadirse explícitamente en los `default.nix` correspondientes (sin auto-import).

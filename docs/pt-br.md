# Documentação ZNix
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

![Banner](../assets/banner.jpg)

Conjunto de configs NixOS/home-manager por host. Abaixo: onde fica cada coisa, opções personalizadas, alerta sobre hardware-configuration e como usar ou adicionar um host.

## Destaques
- SwayFX pré-configurado com Noctalia Shell (painel/barra, saídas, autostart).
- Neovim via nixvim com plugins para LSP, auto-complete, UI/Treesitter, DAP.
- Tema Stylix com cursores/ícones customizados e integração em GTK, fzf, lazygit, noctalia.
- Módulo opcional SillyTavern + Ollama e módulo de portas de dev para LAN.

## Exemplos

- `fastfetch` + nixvim: ![Exemplo 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Exemplo 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Estrutura
- `flake.nix`: entrada; puxa nixpkgs 25.11, home-manager, nixvim, stylix, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: entradas nixosSystem; importam `configuration.nix`, seu `hardware-configuration.nix`, módulos do host (ollama, fprintd/opencode) e HM para `zerok`.
- `configuration.nix`: base do sistema; importa `core/` e `configs/`.
- `core/`: módulos do sistema (boot, nixpkgs, rede, áudio, gráficos, usuários etc.) mais `znix/` para opções customizadas.
- `configs/`: tweaks extras (ex.: `throne.nix`, `zapret.nix`).
- `home/`: config HM para `zerok`; inclui swayfx (`home/sway/`), pacotes, temas, nixvim (`home/nixvim/`) etc.

## Opções personalizadas
- Sistema:
  - `znix.monitors.*` (`home/znix/monitors.nix`): mapa de monitores (modo/posição) e alvo da barra Noctalia.
  - `znix.dev.ports.*` (`core/znix/ports.nix`): abre portas TCP de dev na interface escolhida (`interface`, `tcpPorts`).
  - `znix.ai.sillytavern.*` (`core/znix/silly-tavern.nix`): ativa SillyTavern e Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
  - `znix.hardware.fingerprint.goodix.*` (`core/znix/finger-print.nix`): habilita leitor Goodix (fprintd/TOD).
- Home:
  - `znix.browser.*` (`home/znix/browser.nix`): opções do Firefox (perfil, extensões, favoritos).
  - `znix.theme.*` (`home/znix/theme.nix`): polaridade do tema, pacote de cursores, pacote/nomes de ícones para stylix.

## Aviso sobre hardware-configuration
- `hosts/*/hardware-configuration.nix` é específico da máquina; **substitua** pelo seu (geralmente `/etc/nixos/hardware-configuration.nix` após a instalação).
- Evite commitar configs de hardware de terceiros; mantenha local ou privado.

## Usar um host existente
1) Instale NixOS e ative flakes (`nix.settings.experimental-features = [ "nix-command" "flakes" ];`).
2) Clone o repositório e troque `hosts/<target>/hardware-configuration.nix` pelo seu.
3) Build: `sudo nixos-rebuild switch --flake .#desktop` (ou `.#laptop`).
4) Checagem rápida sem trocar: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`.

## Adicionar um novo host
1) Copie uma pasta `hosts/<name>/` existente e coloque seu `hardware-configuration.nix`.
2) No novo `default.nix`, ajuste `system` e habilite os módulos/overlays necessários.
3) Ajuste HM (posição da barra noctalia, escala de fonte, layout de telas etc.).
4) Build: `nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` ou `sudo nixos-rebuild switch --flake .#<name>`.

## Notas
- home-manager vive dentro dos módulos NixOS (sem output separado `homeConfigurations`).
- Novos módulos devem ser adicionados explicitamente nos `default.nix` correspondentes (sem auto-import).

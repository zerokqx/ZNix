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

Conjunto de configs NixOS/home-manager por host. Abaixo: onde fica cada coisa, opções personalizadas, alerta sobre hardware-configuration e como usar ou adicionar um host.

## Destaques
- SwayFX pré-configurado com Noctalia Shell (painel/barra, saídas, autostart).
- Neovim via nixvim com plugins para LSP, auto-complete, UI/Treesitter, DAP.
- Tema Stylix com cursores/ícones customizados e integração em GTK, fzf, lazygit, noctalia.
- Integração Flatpak via nix-flatpak + pacotes/fontes geridos pelo home-manager.
- Módulo opcional SillyTavern + Ollama e módulo de portas de dev para LAN.

## Exemplos

- `fastfetch` + nixvim: ![Exemplo 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![Exemplo 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## Estrutura
- `flake.nix`: entrada; puxa nixpkgs 25.11, home-manager, nixvim, stylix, nix-flatpak, noctalia, firefox-nightly, flake-parts.
- `hosts/desktop`, `hosts/laptop`: entradas nixosSystem; importam `configuration.nix`, seu `hardware-configuration.nix`, módulos do host (ollama, fprintd/opencode) e HM para `zerok`.
- `configuration.nix`: base do sistema; importa `core/` e `configs/`.
- `core/`: módulos do sistema (boot, nixpkgs, rede, áudio, gráficos, usuários etc.) mais `dev/`, `silly-tavern.nix`, `hardware/`.
- `configs/`: tweaks extras (ex.: `throne.nix`, `zapret.nix`).
- `home/`: config HM para `zerok`; inclui swayfx (`home/sway/`), pacotes, temas, nixvim (`home/nixvim/`) etc.

## Opções personalizadas
- Sistema:
  - `dev.ports.*` (`core/dev/ports.nix`): abre portas TCP de dev na interface escolhida (`interface`, `tcpPorts`).
  - `ai.sillytavern.*` (`core/silly-tavern.nix`): ativa SillyTavern e Ollama (`enable`, `ollamaEnable`, `mobileServer`, `name`).
- Home:
  - `theme.*` (`home/stylix.nix`): polaridade do tema, pacote de cursores, pacote/nomes de ícones para stylix.

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

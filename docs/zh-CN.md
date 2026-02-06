# ZNix 文档
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

![横幅](../assets/banner.jpg)

按主机拆分的 NixOS/home-manager 配置集。下面介绍：目录结构、自定义选项、硬件配置警告，以及如何使用或添加主机。

## 特性
- 预配置的 SwayFX + Noctalia Shell（面板/栏、输出、自动启动）。
- 通过 nixvim 配置的 Neovim，包含 LSP、补全、UI/Treesitter、DAP 插件。
- Stylix 主题，自定义光标/图标，并集成 GTK、fzf、lazygit、noctalia。
- 通过 nix-flatpak 的 Flatpak 集成，以及由 home-manager 管理的包/字体。
- 可选 SillyTavern + Ollama 模块，以及 LAN 开发端口模块。

## 示例

- `fastfetch` + nixvim: ![示例 1](../assets/example-1-fastfetch-nixvim.png)
- Firefox + Bluetooth + Noctalia: ![示例 2](../assets/example-2-firefox-and-bluetooth-noctalia.png)

## 结构
- `flake.nix`：入口；拉取 nixpkgs 25.11、home-manager、nixvim、stylix、nix-flatpak、noctalia、firefox-nightly、flake-parts。
- `hosts/desktop`、`hosts/laptop`：nixosSystem 入口；引入 `configuration.nix`、主机的 `hardware-configuration.nix`、主机模块（ollama、fprintd/opencode）以及用户 `zerok` 的 HM。
- `configuration.nix`：系统基础；导入 `core/` 和 `configs/`。
- `core/`：系统模块（启动、nixpkgs、网络、音频、图形、用户等），以及 `dev/`、`silly-tavern.nix`、`hardware/`。
- `configs/`：额外调整（如 `throne.nix`、`zapret.nix`）。
- `home/`：`zerok` 的 HM 配置；包含 swayfx（`home/sway/`）、软件包、主题、nixvim（`home/nixvim/`）等。

## 自定义选项
- 系统：
  - `dev.ports.*`（`core/dev/ports.nix`）：在指定接口开放开发 TCP 端口（`interface`、`tcpPorts`）。
  - `ai.sillytavern.*`（`core/silly-tavern.nix`）：开关 SillyTavern 与 Ollama（`enable`、`ollamaEnable`、`mobileServer`、`name`）。
- Home：
  - `theme.*`（`home/stylix.nix`）：主题明暗、光标包、图标包/名称（Stylix）。

## 硬件配置警告
- `hosts/*/hardware-configuration.nix` 与机器绑定；请 **替换** 为自己的（通常安装后在 `/etc/nixos/hardware-configuration.nix`）。
- 不要提交他人的硬件配置；请本地或私有保存。

## 使用现有主机
1) 安装 NixOS 并启用 flakes（`nix.settings.experimental-features = [ "nix-command" "flakes" ];`）。
2) 克隆仓库，用你的文件替换 `hosts/<target>/hardware-configuration.nix`。
3) 构建：`sudo nixos-rebuild switch --flake .#desktop`（或 `.#laptop`）。
4) 不切换的快速检查：`nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`。

## 添加新主机
1) 复制现有 `hosts/<name>/` 目录，放入你的 `hardware-configuration.nix`。
2) 在新的 `default.nix` 中设置正确的 `system`，启用需要的模块/overlay。
3) 调整 HM 细节（noctalia 栏位置、字体缩放、显示布局等）。
4) 构建：`nix build .#nixosConfigurations.<name>.config.system.build.toplevel --no-link` 或 `sudo nixos-rebuild switch --flake .#<name>`。

## 备注
- home-manager 嵌入在 NixOS 模块中（无独立 `homeConfigurations` 输出）。
- 新模块需在对应的 `default.nix` 中显式添加（无自动导入）。

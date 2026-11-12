{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) stylix;
  inherit (config.lib.stylix.colors) withHashtag;
  sharedTheme = import ../lib/stylix-theme.nix { inherit pkgs; };
  themeConfig = (pkgs.formats.ini { }).generate "znix-sddm-theme.conf" {
    General = {
      background = withHashtag.base00;
      surface = withHashtag.base01;
      field = withHashtag.base02;
      border = withHashtag.base03;
      foreground = withHashtag.base05;
      accent = withHashtag.base0D;
      secondaryAccent = withHashtag.base0C;
      error = withHashtag.base08;
      fontFamily = stylix.fonts.sansSerif.name;
      fontSize = stylix.fonts.sizes.desktop;
      wallpaper = if stylix.image == null then "" else toString stylix.image;
      surfaceOpacity = lib.max 0.92 stylix.opacity.popups;
    };
  };
  theme = pkgs.runCommand "znix-sddm-theme" { } ''
    mkdir -p "$out/share/sddm/themes/znix"
    cp ${./sddm-theme}/* "$out/share/sddm/themes/znix/"
    ln -s ${themeConfig} "$out/share/sddm/themes/znix/theme.conf"
  '';
  u2f = config.security.pam.u2f;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = lib.mkMerge [
    (lib.mkDefault sharedTheme)
    {
      enable = lib.mkDefault true;
      autoEnable = false;
      # Stylix уже подключён явно в lib/home-modules.nix.
      homeManagerIntegration.autoImport = false;
    }
  ];

  services.displayManager = {
    defaultSession = lib.mkDefault "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = lib.mkIf stylix.enable "${theme}/share/sddm/themes/znix";
    };
  };

  fonts.packages = lib.mkIf stylix.enable [ stylix.fonts.sansSerif.package ];

  # У SDDM собственный PAM-стек. Сохраняем U2F до парольной проверки, как в Ly.
  security.pam.services.sddm = {
    u2f.enable = true;
    rules.auth.u2f = {
      enable = config.security.pam.services.sddm.u2f.enable;
      order = config.security.pam.services.sddm.rules.auth.login.order - 10;
      control = config.security.pam.services.sddm.u2f.control;
      modulePath = "${pkgs.pam_u2f}/lib/security/pam_u2f.so";
      inherit (u2f) settings;
    };
  };
}

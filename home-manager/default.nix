{ config, pkgs, ... }:

{

  imports = [
    ./pkgs-configuration
    ./sway
    ./pkgs.nix
    ./dir-file-create.nix

  ];
  home.username = "zerok";
  home.homeDirectory = "/home/zerok";
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;
  home.language = {
    numeric = "en_US.UTF-8";
    time = "en_US.UTF-8";
    base = "en_US.UTF-8";
    address = "en_US.UTF-8";
    messages = "en_US.UTF-8";
    telephone = "en_US.UTF-8";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.cargo/bin" ];
  home.sessionVariables = {
    TERM = "alacritty";
    XDG_MIME_DEFAULTS = ''
      application/pdf=zathura
      application/x-pdf=zathura
      image/jpeg=org.gnome.Loupe.desktop
      image/png=org.gnome.Loupe.desktop
      image/gif=org.gnome.Loupe.desktop
      image/bmp=org.gnome.Loupe.desktop
      image/webp=org.gnome.Loupe.desktop
      image/svg+xml=org.gnome.Loupe.desktop
      image/tiff=org.gnome.Loupe.desktop
    '';
    MICRO_TRUECOLOR = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.bash.enable = true;

  programs.home-manager.enable = true;
}

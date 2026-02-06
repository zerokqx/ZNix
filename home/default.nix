{
  config,
  ...
}:

{

  imports = [
    ./git.nix
    ./noctalia.nix
    ./stylix.nix
    ./firefox.nix
    ./zoxide.nix
    ./alacritty.nix
    ./fish.nix
    ./nixvim
    ./sway
    ./packages.nix
    ./dir-file-create.nix
    ./flatpak.nix

  ];
  programs.codex.enable = true;
  nixpkgs.config.allowUnfree = true;
  home.username = "zerok";
  home.homeDirectory = "/home/zerok";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  home.language = {
    numeric = "en_US.UTF-8";
    time = "en_US.UTF-8";
    base = "en_US.UTF-8";
    address = "en_US.UTF-8";
    messages = "en_US.UTF-8";
    telephone = "en_US.UTF-8";
  };

  services.udiskie = {
    enable = true;
    settings = {
      automount = true;
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.bun/bin"
  ];
  home.sessionVariables = {
    TERM = "alacritty";
    BROWSER = "firefox";
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
      video/mp4=org.gnome.Totem.desktop
      video/mkv=org.gnome.Totem.desktop
      video/avi=org.gnome.Totem.desktop
    '';
    MICRO_TRUECOLOR = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.home-manager.enable = true;
}

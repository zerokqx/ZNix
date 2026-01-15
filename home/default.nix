{
  config,
  pkgs,
  inputs,
  ...
}:

{

  imports = [

    ./git.nix
    ./alacritty.nix
    ./noctalia.nix
    ./stylix
    ./gtk.nix
    ./firefox.nix
    ./zoxide.nix
    ./fish.nix
    ./nixvim
    ./sway
    ./packages.nix
    ./dir-file-create.nix

  ];

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
    '';
    MICRO_TRUECOLOR = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.bash.enable = true;
  programs.home-manager.enable = true;
}

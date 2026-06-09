{
  config,
  ...
}:

{

  imports = [
    # ./zed.nix
    # ./niri
    ./hyprland
    ./mimes.nix
    ./git.nix
    ./noctalia.nix
    ./znix
    ./zoxide.nix
    ./alacritty.nix
    ./fish.nix
    ./nixvim
    ./packages.nix
    ./dir-file-create.nix
  ];

  nixpkgs.config.allowUnfree = true;
  home.username = "zerok";
  home.homeDirectory = "/home/zerok";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  home.language = {
    numeric = "ru_RU.UTF-8";
    time = "ru_RU.UTF-8";
    base = "en_US.UTF-8";
    address = "en_US.UTF-8";
    messages = "en_US.UTF-8";
    telephone = "en_US.UTF-8";
  };

  services.ssh-agent.enable = true;
  services.udiskie = {
    enable = true;
    settings = {
      automount = true;
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
  ];
  home.sessionVariables = {
    TERM = "alacritty";
    BROWSER = "firefox-nightly";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.home-manager.enable = true;
}

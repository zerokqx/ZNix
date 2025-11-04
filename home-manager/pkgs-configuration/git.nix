{ ... }: {
  programs.git = let config = (import ../../config.nix) { key = "git"; };
  in {
    enable = true;
    userName = config.userName;
    userEmail = config.userEmail;
  };

}

{
  imports = [ ./hardware-configuration.nix ];

  home-manager.users.zerok = {
    # The registry also selects the personal Home Manager profile.
    imports = [ ../../home/noop ];
    programs.dank-material-shell.enable = true;
  };
}

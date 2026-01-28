{ inputs, ... }:
{

  programs.nixvim = {
    enable = true;
    imports = [
      ./autocmds.nix
      ./languages
      ./plugins
      ./keymaps.nix
      ./opts.nix

    ];
  };
}

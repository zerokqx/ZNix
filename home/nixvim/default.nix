{ inputs, ... }:
{

  programs.nixvim = {
    fileManager = "snacks";
    enable = true;
    imports = [
      ./options.nix
      ./languages
      ./plugins
      ./keymaps.nix
      ./opts.nix

    ];
  };
}

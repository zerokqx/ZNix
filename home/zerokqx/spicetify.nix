{ inputs, ... }:
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  # Ставит Spotify с spicetify; цвета задаёт stylix через autoEnable
  programs.spicetify.enable = true;
}

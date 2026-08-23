{ pkgs, ... }:
{

  nix.settings = {
    trusted-users = [
      "root"
      "zerok"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.3.4"
    "nodejs-slim-20.20.2"
  ];

  # zapret uses multiport with dash-ranges (e.g. 50000-65535),
  # which nf_tables rejects; legacy backend handles it correctly.
  # But with colon range (50000:65535) nftables handles it natively.
  # networking.firewall.package = pkgs.iptables-legacy;
}


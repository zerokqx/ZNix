{
  inputs,
  pkgs,
  nixosConfigurations,
  homeConfigurations,
}:
let
  inherit (pkgs.lib) all assertMsg mapAttrsToList;
  inherit (import ../lib inputs) mkHost;

  expectedSystem = "x86_64-linux";
  defaultHost = mkHost {
    system = expectedSystem;
    modules = [ ];
  };
  mismatchedHost = mkHost {
    system = expectedSystem;
    modules = [
      ({ lib, ... }: { nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux"; })
    ];
  };

  policy = import ../lib/package-policy.nix;
  matchesPackagePolicy =
    config:
    config.allowUnfree == policy.allowUnfree
    && config.permittedInsecurePackages == policy.permittedInsecurePackages;

  checkHost =
    name: hostName:
    let
      cfg = nixosConfigurations.${name}.config;
      home = cfg.home-manager.users.zerok;
    in
    assert assertMsg (cfg.networking.hostName == hostName) "${name}: changed system hostname";
    assert assertMsg (
      cfg.nixpkgs.hostPlatform.system == expectedSystem && cfg.system.stateVersion == "26.05"
    ) "${name}: changed platform or system.stateVersion";
    assert assertMsg (
      cfg.programs.hyprland.enable
      && cfg.programs.steam.enable
      && cfg.virtualisation.docker.enable
      && cfg.znix.dev.ports.enable
    ) "${name}: missing workstation or development settings";
    assert assertMsg (
      cfg.home-manager.useGlobalPkgs
      && cfg.home-manager.useUserPackages
      && home.home.stateVersion == "26.05"
      && home.programs.ssh.enable
      && home.programs.dank-material-shell.enable
    ) "${name}: missing integrated personal Home Manager settings";
    assert assertMsg (matchesPackagePolicy cfg.nixpkgs.config) "${name}: inconsistent package policy";
    true;

  checkHome =
    name: personal:
    let
      cfg = homeConfigurations.${name}.config;
    in
    assert assertMsg (
      cfg.home.username == "zerok" && cfg.home.stateVersion == "26.05"
    ) "${name}: changed Home Manager account or stateVersion";
    assert assertMsg (
      cfg.programs.ssh.enable == personal && cfg.programs.dank-material-shell.enable
    ) "${name}: changed standalone Home Manager profile";
    assert assertMsg (matchesPackagePolicy cfg.nixpkgs.config) "${name}: inconsistent package policy";
    true;
in
assert assertMsg (
  defaultHost.config.nixpkgs.hostPlatform.system == expectedSystem
) "mkHost did not provide the registry platform by default";
assert assertMsg (
  !(builtins.tryEval mismatchedHost).success
) "mkHost accepted a mismatched hostPlatform";
assert all (ok: ok) (
  mapAttrsToList checkHost {
    desktop = "nixos-pc";
    laptop = "nixos-laptop";
    noop = "nixos";
  }
);
assert all (ok: ok) (
  mapAttrsToList checkHome {
    noop = false;
    zerok = true;
    zerokqx = true;
  }
);
pkgs.runCommand "znix-configuration-contracts" { } ''
  touch "$out"
''

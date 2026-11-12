{ inputs, ... }:
let
  inherit (import ../lib inputs) mkHost mkHome;

  homes = {
    zerokqx = mkHome {
      system = "x86_64-linux";
      module = ../home/zerokqx;
    };
    noop = mkHome {
      system = "x86_64-linux";
      module = ../home/noop;
    };
    # znix-installer:homes
  };
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkHost {
        system = "x86_64-linux";
        modules = [
          ../profiles/workstation.nix
          ../profiles/personal.nix
          ./desktop
        ];
      };
      laptop = mkHost {
        system = "x86_64-linux";
        modules = [
          ../profiles/workstation.nix
          ../profiles/personal.nix
          ./laptop
        ];
      };
      noop = mkHost {
        system = "x86_64-linux";
        modules = [
          ../profiles/workstation.nix
          ../profiles/personal.nix
          ./noop
        ];
      };
      # znix-installer:hosts
    };

    homeConfigurations = homes // {
      zerok = homes.zerokqx;
    };
  };
}

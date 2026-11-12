{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = with pkgs; [
          nixfmt
          shfmt
          prettier
          taplo
        ];
        settings = {
          on-unmatched = "info";
          formatter = {
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };
            shfmt = {
              command = "shfmt";
              includes = [
                "*.sh"
                ".envrc"
              ];
              options = [
                "-i"
                "2"
                "-w"
              ];
            };
            prettier = {
              command = "prettier";
              includes = [
                "*.md"
                "*.yaml"
                "*.yml"
                "*.json"
              ];
              options = [ "--write" ];
            };
            taplo = {
              command = "taplo";
              includes = [ "*.toml" ];
              options = [ "format" ];
            };
          };
        };
      };
    in
    {
      inherit formatter;
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          bash
          git
          jq
          python3
          shellcheck
          nixfmt
          formatter
        ];
      };

      checks = {
        celestia-stylix = import ../tests/celestia-stylix.nix { inherit pkgs inputs; };
        desktop-shells = import ../tests/desktop-shells.nix {
          inherit pkgs;
          inherit (inputs.self) homeConfigurations;
        };
        configurations = import ../tests/configurations.nix {
          inherit pkgs;
          inherit (inputs.self) nixosConfigurations homeConfigurations;
        };
        workflow =
          pkgs.runCommand "znix-workflow"
            {
              nativeBuildInputs = with pkgs; [
                bash
                git
                python3
                shellcheck
              ];
            }
            ''
              cp -r ${../scripts} scripts
              cp -r ${../tests} tests
              shellcheck scripts/*.sh
              python3 -B -m unittest discover -s tests
              touch "$out"
            '';
      };

      packages.dev-ports-test = pkgs.testers.runNixOSTest {
        imports = [ ../tests/dev-ports.nix ];
      };
    };
}

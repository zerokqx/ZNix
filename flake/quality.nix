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

      devShells.liquid-background = pkgs.mkShell {
        packages = [
          (pkgs.python3.withPackages (ps: [ ps.moderngl ]))
          pkgs.ffmpeg-headless
        ];
        GLCONTEXT_LINUX_LIBGL = "${pkgs.libglvnd}/lib/libGL.so.1";
        GLCONTEXT_LINUX_LIBEGL = "${pkgs.libglvnd}/lib/libEGL.so.1";
        __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
      };

      checks = {
        chromium-devtools = import ../tests/chromium-devtools.nix { inherit pkgs inputs; };
        ayugram-stylix = import ../tests/ayugram-stylix.nix { inherit pkgs inputs; };
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
              mkdir -p home/zerokqx/clipboard
              cp ${../home/zerokqx/clipboard/history.py} home/zerokqx/clipboard/history.py
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

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) stylix;
  useStylix = stylix.enable && stylix.targets.celestia.enable;
  package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.override (
    lib.optionalAttrs useStylix {
      # The upstream wrapper uses its own Fontconfig file.
      makeFontsConf =
        args:
        pkgs.makeFontsConf (
          args
          // {
            fontDirectories = args.fontDirectories ++ [
              stylix.fonts.sansSerif.package
              stylix.fonts.monospace.package
            ];
          }
        );
    }
  );
  clipboardBackend = pkgs.callPackage ./clipboard { };
in
{
  imports = [
    ./dms.nix
    ./znix/stylix-celestia.nix
  ];

  assertions = [
    {
      assertion = config.programs.caelestia.enable != config.programs.dank-material-shell.enable;
      message = "Enable exactly one desktop shell: Caelestia or Dank Material Shell.";
    }
  ];

  # Both shells render their own wallpaper.
  stylix.targets.hyprland.hyprpaper.enable = lib.mkDefault false;

  programs.caelestia = {
    enable = lib.mkDefault true;
    package = lib.mkDefault (
      package.overrideAttrs (old: {
        patches =
          (old.patches or [ ])
          ++ [
            ./clipboard/caelestia.patch
            ./audio/caelestia.patch
            ./media/caelestia.patch
            ./translator/caelestia.patch
            ./notifications/caelestia.patch
          ]
          ++ lib.optional useStylix ./znix/caelestia-stylix.patch;
        postPatch = (old.postPatch or "") + ''
          substitute ${./clipboard/ClipboardDrawer.qml} modules/drawers/ClipboardDrawer.qml \
            --replace-fail '@clipboardBackend@' '${lib.getExe clipboardBackend}'
          substitute ${./translator/Translator.qml} modules/utilities/Translator.qml \
            --replace-fail '@translateShell@' '${lib.getExe pkgs.translate-shell}' \
            --replace-fail '@timeout@' '${lib.getExe' pkgs.coreutils "timeout"}'
        '';
      })
    );
    # Restart the shell when its Nix store path changes during activation.
    systemd.enable = true;
    cli.enable = true;

    settings = {
      general.idle = {
        # Preserve the existing session policy without automatic lock, DPMS or suspend.
        timeouts = lib.mkDefault [ ];
        lockBeforeSleep = lib.mkDefault false;
      };

      utilities.toasts.kbLayoutChanged = lib.mkDefault false;

      # Caelestia replaces the whole list. Audio and microphone open the same popout.
      bar.statusIcons = lib.mkDefault [
        {
          id = "lockStatus";
          enabled = true;
        }
        {
          id = "audio";
          enabled = true;
        }
        {
          id = "microphone";
          enabled = true;
        }
        {
          id = "kbLayout";
          enabled = true;
        }
        {
          id = "network";
          enabled = true;
        }
        {
          id = "bluetooth";
          enabled = true;
        }
        {
          id = "battery";
          enabled = true;
        }
      ];
    };
  };
}

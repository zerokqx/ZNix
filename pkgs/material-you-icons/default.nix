{
  lib,
  runCommand,
  makeWrapper,
  fetchFromGitHub,
  fetchurl,
  python3,
  python313,
  librsvg,
  writeShellScript,
  uv,
  git,
  gcc16,
  zlib,
  zstd,
  xz,
  bzip2,
  rocm ? false,
  gfxOverride ? null,
}:
let
  pname = "material-you-icons";
  version = "0.1.0";
  mobileSam = fetchFromGitHub {
    owner = "ChaoningZhang";
    repo = "MobileSAM";
    rev = "f706ad9c4eb7f219c00d9050e46328518ffb65d2";
    hash = "sha256-p6855j4zT5TdgSQcPTa7Lay3+DuKQ5GSe/fI5jdCxIo=";
  };
  checkpoint = fetchurl {
    url = "https://raw.githubusercontent.com/ChaoningZhang/MobileSAM/f706ad9c4eb7f219c00d9050e46328518ffb65d2/weights/mobile_sam.pt";
    hash = "sha256-bbuQUjo1Mw/t1/HT38ZvmVIT2BsppcqBCNvN1ON9bC8=";
  };
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.pillow
    ps.torchWithoutCuda
    (ps.torchvision.override { torch = ps.torchWithoutCuda; })
    ps.timm
  ]);
  rocmPython = writeShellScript "material-you-icons-rocm-python" ''
    export UV_PROJECT_ENVIRONMENT="''${XDG_CACHE_HOME:-$HOME/.cache}/material-you-icons/rocm-7.2-py313"
    export UV_PYTHON_DOWNLOADS=never
    export HSA_TOOLS_DISABLE_REGISTER="''${HSA_TOOLS_DISABLE_REGISTER:-1}"
    ${lib.optionalString (gfxOverride != null) ''
      if [ -z "''${HSA_OVERRIDE_GFX_VERSION:-}" ]; then
        export HSA_OVERRIDE_GFX_VERSION=${lib.escapeShellArg gfxOverride}
      fi
    ''}
    exec ${uv}/bin/uv run --project ${./rocm} --locked \
      --python ${python313}/bin/python3.13 -- python "$@"
  '';
  python = if rocm then rocmPython else "${pythonEnv}/bin/python";
in
runCommand "${pname}-${version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    meta = {
      description = "Apply a Material You icon style to installed application icons";
      platforms = [ "x86_64-linux" ];
      mainProgram = "render-icon";
    };
  }
  ''
    mkdir -p "$out/share/${pname}" "$out/bin"
    cp -r ${./src} "$out/share/${pname}/src"
    cp -r ${./assets} "$out/share/${pname}/assets"
    chmod -R u+w "$out/share/${pname}/src"
    find "$out/share/${pname}/src" -type d -name __pycache__ -prune -exec rm -rf {} +
    makeWrapper ${python} "$out/bin/render-icon" \
      --add-flags "$out/share/${pname}/src/main.py" \
      --prefix PATH : "${librsvg}/bin" \
      --set MATERIAL_YOU_ICONS_WEIGHTS "${checkpoint}" \
      ${
        if rocm then
          ''
            --prefix PATH : "${
              lib.makeBinPath [
                git
                gcc16
              ]
            }" \
            --prefix LD_LIBRARY_PATH : "${
              lib.makeLibraryPath [
                gcc16.cc.lib
                zlib
                zstd
                xz
                bzip2
              ]
            }"
          ''
        else
          ''
            --prefix PYTHONPATH : "${mobileSam}"
          ''
      }
  ''

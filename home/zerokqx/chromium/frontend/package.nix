{
  runCommand,
  binutils,
  python3,
  chromium,
  paletteCss,
}:
let
  python = python3.withPackages (ps: [
    ps.brotli
    ps.pyelftools
  ]);
in
runCommand "znix-chromium-devtools-${chromium.version}" { nativeBuildInputs = [ binutils ]; } ''
  ${python}/bin/python ${./build.py} \
    "${chromium.browser}/libexec/chromium/chromium" "$out" \
    ${./.} ${if paletteCss == null then "" else paletteCss}
''

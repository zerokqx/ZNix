{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "pachca";
  version = "2.13.0";
  # The mutable latest URL is pinned by this hash; update both with the version.
  src = fetchurl {
    url = "https://install.pachca.com/linux/appImage/x64/pachca-latest-x86_64.AppImage";
    hash = "sha256-8Ckr/IEvF4/xJ1e4JX7gXfZjlhRQdmGWKX0wXS/9IHw=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/Pachca.desktop $out/share/applications/pachca.desktop
    substituteInPlace $out/share/applications/pachca.desktop \
      --replace-fail 'Exec=AppRun ' 'Exec=pachca '
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Corporate messenger";
    homepage = "https://pachca.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}

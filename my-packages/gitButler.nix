{pkgs}:
pkgs.stdenv.mkDerivation rec {
  pname = "meu-app-legal";
  version = "1.2.3";
  src = pkgs.fetchurl {
    url = "https://github.com/usuario/repo/releases/download/v${version}/MeuAppLegal-${version}.AppImage";
    sha256 = "0s1h7z9f2kcnv8p8g8z1j7r6q0g7wzq4x9k7m8n5p5y4l3a3i2b1"; # SUBSTITUIR HASH
  };
  nativeBuildInputs = [pkgs.makeWrapper];
  buildInputs = [pkgs.appimage-run];
  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src $out/meu-app-legal.AppImage
    chmod +x $out/meu-app-legal.AppImage
    makeWrapper ${pkgs.appimage-run}/bin/appimage-run $out/bin/meu-app-legal --add-flags $out/meu-app-legal.AppImage
    runHook postInstall
  '';
  meta = with pkgs.lib; {
    /*
    ... metadados ...
    */
  };
}

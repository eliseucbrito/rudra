{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "cherry-studio";
  version = "1.2.10";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/CherryHQ/cherry-studio/releases/download/v1.2.10/Cherry-Studio-1.2.10-x86_64.AppImage";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  appimageContents = appimageTools.extractType2 {inherit name src;};
in
  appimageTools.wrapType2 {
    inherit name src;

    extraInstallCommands = ''
      mkdir -p $out/share/applications

      cat > $out/share/applications/${pname}.desktop << EOF
      [Desktop Entry]
      Type=Application
      Name=Cherry Studio
      Exec=${pname}
      Icon=${pname}
      Comment=AI-powered development environment
      Categories=Development;IDE;
      EOF

      mkdir -p $out/share/icons/hicolor/512x512/apps

      ICON_FILES=$(find ${appimageContents} -name "*.png" -o -name "*.svg" -o -name "*.xpm")
      if [ -n "$ICON_FILES" ]; then
        for icon_file in $ICON_FILES; do
          cp "$icon_file" $out/share/icons/hicolor/512x512/apps/${pname}$(basename "$icon_file" | sed 's/^[^.]*//') || true
        done
      fi

      mkdir -p $out/bin
      ln -s $out/bin/.${pname}-wrapped $out/bin/${pname}
    '';

    meta = with lib; {
      description = "Cherry Studio - AI-powered development environment";
      homepage = "https://github.com/CherryHQ/cherry-studio";
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
      maintainers = [];
      mainProgram = pname;
    };
  }

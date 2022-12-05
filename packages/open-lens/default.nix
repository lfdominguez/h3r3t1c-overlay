{ lib, fetchurl, appimageTools, wrapGAppsHook, gsettings-desktop-schemas, gtk3 }:

let
  pname = "open-lens";
  version = "6.2.4";

  src = fetchurl {
    url = "https://github.com/MuhammedKalkan/OpenLens/releases/download/v${version}/OpenLens-${version}.x86_64.AppImage";
    sha256 = "sha256-a12183339479462a618e5de081b8ef41c4f6254699d4a030da599a1cd7edc8a6";
    name = "${pname}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

in
appimageTools.wrapType2 {
  inherit name src;

  profile = ''
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  extraInstallCommands =
    ''
      #mv $out/bin/${name} $out/bin/${pname}

      install -m 444 -D ${appimageContents}/open-lens.desktop $out/share/applications/${pname}.desktop
      install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/open-lens.png \
         $out/share/icons/hicolor/512x512/apps/${pname}.png

      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Icon=lens' 'Icon=open-lens' \
        --replace 'Exec=AppRun' 'Exec=open-lens'
    '';

  meta = with lib; {
    description = "The Kubernetes Opens IDE";
    homepage = "https://k8slens.dev/";
    license = licenses.mit;
    maintainers = with maintainers; [ lfdominguez ];
    platforms = [ "x86_64-linux" ];
  };
}

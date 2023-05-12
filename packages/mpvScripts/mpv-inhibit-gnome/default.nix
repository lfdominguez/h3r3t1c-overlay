{ lib, stdenv, fetchFromGitHub, dbus, pkg-config, mpv }:

stdenv.mkDerivation rec {
  pname = "mpv-inhibit-gnome";
  version = "master";

  src = fetchFromGitHub {
    owner = "Guldoman";
    repo = "mpv_inhibit_gnome";
    rev = version;
    sha256 = "sha256-pYFlUijn2UhRS3m7iUTwePC0W5Fgvj5axrUg7VjD6XM=";
  };

  nativeBuildInputs = [
    dbus
    stdenv
    pkg-config
    mpv
  ];

  postPatch = ''
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    cp lib/mpv_inhibit_gnome.so $out/share/mpv/scripts
    runHook postInstall
  '';

  meta = with lib; {
    description = "This mpv plugin prevents screen blanking in GNOME";
    homepage = "https://github.com/Guldoman/mpv_inhibit_gnome";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ lfdominguez ];
  };
}

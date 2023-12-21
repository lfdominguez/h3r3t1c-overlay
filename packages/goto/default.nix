{ stdenv, lib
, fetchzip
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "goto";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/grafviktor/goto/releases/download/v${version}/goto-v${version}.zip";
    hash = "sha256-CvpunqDLsGE0BxEghsEyMFZ1uLyhV20t/VsapWm01RQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D source/gg-lin $out/bin/goto
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/grafviktor/goto";
    description = "A simple SSH manager that provides you with easy access to a list of your favorite SSH servers. Binaries included! 😉";
    platforms = platforms.linux;
  };
}

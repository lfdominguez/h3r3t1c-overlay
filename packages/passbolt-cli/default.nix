{ stdenv, lib
, fetchzip
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "passbolt-cli";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/passbolt/go-passbolt-cli/releases/download/v${version}/go-passbolt-cli_${version}_linux_amd64.tar.gz";
    hash = "sha256-ucB73uxk+CUioVb2xYD9ZQatQ70pO2dQecxYMUkFp/k=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D source/passbolt $out/bin/passbolt-cli
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/passbolt/go-passbolt-cli";
    description = "A CLI tool to interact with Passbolt, a Open source Password Manager for Teams";
    platforms = platforms.linux;
  };
}

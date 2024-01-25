{ stdenv, lib
, fetchzip
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "passbolt-cli";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/passbolt/go-passbolt-cli/releases/download/v${version}/go-passbolt-cli_${version}_linux_amd64.tar.gz";
    hash = "sha256-5/47GUjLx8SDIAvlAmWq8UxCDAVK4pQT1O7tWbdtQts=";
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
    install -m755 -D source/passbolt $out/bin/passbolt
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/passbolt/go-passbolt-cli";
    description = "A CLI tool to interact with Passbolt, a Open source Password Manager for Teams";
    platforms = platforms.linux;
  };
}

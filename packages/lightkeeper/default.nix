{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkgs
}:

rustPlatform.buildRustPackage rec {
  pname = "lightkeeper";
  version = "0.15.1";

  rust = "1.75";

  src = fetchFromGitHub {
    owner = "kalaksi";
    repo = "lightkeeper";
    rev = "v${version}";
    hash = "sha256-Uatm59/Q+DIdacn2hPYus3FublE60kG4EETePDLYCXY=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    dbus.dev
    qt5.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qt5.qtdeclarative
    qt5.qtbase

    liboping
    dbus.lib
  ];

  cargoHash = "sha256-8j5Jsf9wFFlyyoIIuySNRiPXBeQSOOB8HF2G/xWV2Mo=";

  meta = with lib; {
    description = "A modular drop-in replacement for maintaining servers over SSH with shell commands";
    longDescription = ''
     LightkeeperRM (Remote Management) is a modular drop-in replacement for 
     maintaining servers over SSH with shell commands. No additional daemons 
     or other software is needed on target hosts. LightkeeperRM will only run 
     standard Linux commands already available on the host. You can see executed 
     commands through debug log and on target hosts's logs (depending on setup), 
     so it's easy to audit and debug.
    '';
    homepage = "https://github.com/kalaksi/lightkeeper";
    license = licenses.gpl3;
    maintainers = [ maintainers.lfdominguez ];
    platforms = platforms.all;
  };
}

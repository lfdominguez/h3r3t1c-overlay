{ lib
, cmake
, fetchFromGitHub
, stdenv

, xorg
, pugixml
, libxkbcommon
, glib
, gdk-pixbuf
, pcre2
, util-linux
, libnotify
, libselinux
, qt6
, libei
, libportal
, cli11
, tomlplusplus
, gtest

, config

, pkg-config
, patchelf
}:

let

in
stdenv.mkDerivation (finalAttrs: {
  pname = "deskflow";
  version = "v1.18.0";

  src = fetchFromGitHub {
    owner = "deskflow";
    repo = "deskflow";
    rev = "${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-S6YKpYwNzFm9FTFrIm2JpMly475xXW3hNQ1SHByiauw=";
  };

  patches = [ ./patches/patch.diff ];

  # postPatch = ''
  #   substituteInPlace ./ggml-metal.m \
  #     --replace '[bundle pathForResource:@"ggml-metal" ofType:@"metal"];' "@\"$out/bin/ggml-metal.metal\";"
  # '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    gtest
  ];

  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXtst
    xorg.libxkbfile
    libxkbcommon
    pugixml
    glib
    gdk-pixbuf
    pcre2
    util-linux.dev
    libnotify
    libselinux
    qt6.qtbase
    libei
    libportal
    cli11
    tomlplusplus
  ];

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  meta = with lib; {
    description = "Deskflow lets you share one mouse and keyboard between multiple computers on Windows, macOS and Linux. It's like a software KVM (but without video).";
    homepage = "https://deskflow.org";
    license = licenses.gpl2;
    mainProgram = "deskflow";
    maintainers = with maintainers; [ lfdominguez ];
    platforms = platforms.unix;
  };
})

{
  stdenv,
  lib,
  fetchFromGitHub,
  #doxygen,
  #graphviz,
  #kdoctools,
  wrapQtAppsHook,
  autoPatchelfHook,

  cmake,
  qt6,
  kdePackages,

  alkimia_qt6,

  aqbanking,
  gmp,
  gwenhywfar,
  libical,
  libofx,

  sqlcipher,

  # Needed for running tests:
  xvfb-run,

  python3,
}:

stdenv.mkDerivation rec {
  pname = "kmymoney";
  version = "master";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "kmymoney";
    rev = "2e9932d0facd3944e53b6d3a882a8d6a5d4b2ce7";
    sha256 = "sha256-1CZmaK6aiOq5WxL1i6MNLaoPUzNB7TLdAogNHp5E1us=";
  };

  cmakeFlags = [
#    "-DQT_MAJOR_VERSION=6"
    "-DBUILD_WITH_QT6=true"
    "-DBUILD_WITH_QT6_CONFIRMED=true"
  ];

  # Hidden dependency that wasn't included in CMakeLists.txt:
#  env.NIX_CFLAGS_COMPILE = "-I${kitemmodels.dev}/include/KF6";

  nativeBuildInputs = [
#    doxygen
    cmake
    kdePackages.extra-cmake-modules
#    graphviz
#    kdoctools
    python3.pkgs.wrapPython
    wrapQtAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtdeclarative
    qt6.qtwebengine
    
    kdePackages.qgpgme

    kdePackages.karchive
    kdePackages.kcoreaddons
    kdePackages.kconfig
    kdePackages.kconfigwidgets
    kdePackages.ki18n
    kdePackages.kcompletion
    kdePackages.kcmutils
    kdePackages.kitemmodels
    kdePackages.kitemviews
    kdePackages.kservice
    kdePackages.kxmlgui
    kdePackages.kholidays
    kdePackages.kcontacts
    kdePackages.plasma-activities
    kdePackages.qtkeychain
    kdePackages.kdiagram

    alkimia_qt6

    aqbanking
    gmp
    gwenhywfar
    libical
    libofx
    sqlcipher

    # Put it into buildInputs so that CMake can find it, even though we patch
    # it into the interface later.
    python3.pkgs.woob
  ];

  postPatch = ''
    buildPythonPath "${python3.pkgs.woob}"
    patchPythonScript "kmymoney/plugins/woob/interface/kmymoneywoob.py"

    # Within the embedded Python interpreter, sys.argv is unavailable, so let's
    # assign it to a dummy value so that the assignment of sys.argv[0] injected
    # by patchPythonScript doesn't fail:
    sed -i -e '1i import sys; sys.argv = [""]' \
      "kmymoney/plugins/woob/interface/kmymoneywoob.py"
  '';

  doInstallCheck = false;

  # libpython is required by the python interpreter embedded in kmymoney, so we
  # need to explicitly tell autoPatchelf about it.
  postFixup = ''
    patchelf --debug --add-needed libpython${python3.pythonVersion}.so \
      "$out/bin/.kmymoney-wrapped"
  '';

  meta = {
    description = "Personal finance manager for KDE";
    mainProgram = "kmymoney";
    homepage = "https://kmymoney.org/";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      aidalgol
      das-g
    ];
  };
}

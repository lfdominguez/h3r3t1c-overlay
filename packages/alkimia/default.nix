{
  fetchFromGitHub,

  cmake,

  qt6,
  kdePackages,

#  fetchurl,
  stdenv,
  lib,
#  extra-cmake-modules,
#  doxygen,
#  graphviz,
#  qtbase,
#  qtwebengine,
  mpir,
#  kdelibs4support,
#  plasma-framework,
#  knewstuff,
#  kpackage,
}:

stdenv.mkDerivation rec {
  pname = "alkimia";
  version = "master";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "alkimia";
    rev = "53b2b07c7bd50aed91b3b5442a2b302b625deb99";
    sha256 = "sha256-ly7KWPkRfNIYdtJNc8KvwHQzlemYUXAlYyl1abFf7OM=";
  };

  cmakeFlags = [
    "-DBUILD_APPLETS=OFF"
    "-DBUILD_WITH_QT6=ON"
  ];

  dontWrapQtApps = true;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
#    doxygen
#    graphviz
  ];

  # qtwebengine is not a mandatory dependency, but it adds some features
  # we might need for alkimia's dependents. See:
  # https://github.com/KDE/alkimia/blob/v8.1.2/CMakeLists.txt#L124
  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine

    kdePackages.systemsettings
    kdePackages.knewstuff

#    qtbase
#    qtwebengine
#    kdelibs4support
#    plasma-framework
#    knewstuff
#    kpackage
  ];
  propagatedBuildInputs = [ mpir ];

  meta = {
    description = "Library used by KDE finance applications";
    mainProgram = "onlinequoteseditor5";
    longDescription = ''
      Alkimia is the infrastructure for common storage and business
      logic that will be used by all financial applications in KDE.

      The target is to share financial related information over
      application boundaries.
    '';
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
}

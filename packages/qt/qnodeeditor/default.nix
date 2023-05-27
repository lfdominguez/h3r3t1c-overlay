{ lib
, stdenv
, fetchFromGitHub
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "nodeeditor";
  version = "3.0.10-master";

  src = fetchFromGitHub {
    owner = "paceholder";
    repo = "nodeeditor";
    rev = "5465ddc91f1b30823c5fc3def93138cbec4c9394";
    sha256 = "lrVTGB2TfusHcEBkk4klUwd2eK+FZKpi+rpx+u9ivDY=";
  };

  buildInputs = with pkgs; [
    qt6.full
    qt6.qtbase
    qt6.wrapQtAppsHook

    cmake
    ninja
  ];

  meta = with lib; {
    description = "Qt Node Editor. Dataflow programming framework";
    longDescription = ''
      QtNodes is conceived as a general-purpose Qt-based library aimed at developing 
      Node Editors for various applications. The library could be used for simple 
      graph visualization and editing or extended further for using the Dataflow paradigm.
    '';
    homepage = "https://github.com/paceholder/nodeeditor";
    license = licenses.bsd3;
    maintainers = [ maintainers.lfdominguez ];
    platforms = platforms.all;
  };
}

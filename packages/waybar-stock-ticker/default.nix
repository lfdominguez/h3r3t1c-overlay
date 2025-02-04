{ lib
, stdenv
, fetchFromGitLab
, python3Packages
, pkgs
}:
let
in python3Packages.buildPythonApplication {
  pname ="waybar-stock-ticker";
  version = "master";

  src = fetchFromGitLab {
    owner = "dstewart";
    repo = "waybar-stock-ticker";
    rev = version;
    hash = "";
  }

  ropagatedBuildInputs = [
    python3Packages.yfinance
  ];

  installPhase = ''
    install -Dm755 "__main__.py" "$out/bin/${pname}"
  '';
}

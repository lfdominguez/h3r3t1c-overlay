{ lib
, stdenv
, fetchFromGitHub
, pkgs
, pyproject-nix
, python3
}:

let 
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "NeMo";
    rev = "refs/tags/v${version}";
    hash = "sha256-K9AGCOuG/trtYukUUhj1grdpVu1+/UJDBH3ILiFJolM=";
    fetchSubmodules = true;
  };

  nemo_project = pyproject-nix.lib.project.loadRequirementsTxt { 
    requirements = builtins.readFile "${src}/requirements/requirements_asr.txt"; 
    projectRoot = src;
  };

  python = python3;

  pythonEnv =
    assert nemo_project.validators.validateVersionConstraints { inherit python; } == { }; (
      python.withPackages (nemo_project.renderers.withPackages {
        inherit python;
      })
    );

in pythonEnv.buildPythonPackage {

  buildInputs = [
    pythonEnv
  ];
  
}
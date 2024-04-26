{
  poetry2nix
, pkgs
, fetchFromGitHub
}:

let
  inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
in mkPoetryApplication {
  projectDir = fetchFromGitHub {
    owner = "Memrise";
    repo = "copypod";
    rev = "main";
    hash = "sha256-QGXvsc9UXyo5Dp21Icjx5SPawGuZbO8VQ5XnZ76U3+Q=";
  };
}
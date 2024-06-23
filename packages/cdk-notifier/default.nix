{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, pkgs
}:

buildGoModule rec {
  pname = "cdk-notifier";
  version = "2.12.7";

  checkPhase = ''
  '';

  src = fetchFromGitHub {
    owner = "karlderkaefer";
    repo = "cdk-notifier";
    rev = "v${version}";
    hash = "sha256-D772omgSWRrzp6LgzXKuunUxkE8dHkRB+2cdOsA8Jjo=";
  };

  vendorHash = "sha256-J4fUQG2EvGUJx5pioYux4i32x1+YotFLyhSVsaHzbSo=";

  CGO_ENABLED = 0;

  postInstall = ''
    ${pkgs.upx}/bin/upx -9 --lzma $out/bin/cdk-notifier
  '';

  meta = {
    description = "CLI tool to post AWS CDK diff as comment to Github pull request ";
    homepage = "https://github.com/karlderkaefer/cdk-notifier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lfdominguez ];
  };
}
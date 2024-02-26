{ lib
, stdenv
, rustPlatform
, fetchCrate
, pkg-config
, openssl
, darwin
, pkgs
}:

rustPlatform.buildRustPackage rec {
  pname = "loco-cli";
  version = "0.2.5";

  rust = "1.75";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-rs3bOH5aYyiPRXgiXqoTfnXvXJqvacMu3ao1Ovq+l+I=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ]
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  cargoHash = "sha256-MRxLuC/MM5JQhl8s/9vNmf17gHre2CK96fEvO1Xboss=";

  meta = with lib; {
    homepage = "https://loco.rs/";
    description = " Command line utility for LOCO, the one-person framework for Rust for side-projects and startups";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ lfdominguez ];
  };
}

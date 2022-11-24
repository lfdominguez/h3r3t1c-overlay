{
    description = "My own overlay";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-22.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
        system = "x86_64-linux";

        mynixpkgs-unstable = import nixos-unstable {
            inherit system

            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;
        };

        overlay-unstable = final: prev: {
            unstable = mynixpkgs-unstable.legacyPackages.x86_64-linux;
        };

        pkgs = import nixpkgs {
            inherit system;

            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;

            overlays = [
                overlay-unstable
                self.overlays.default
            ];

            config.allowUnfree = true;
        };
    in {
        overlays.default = final: prev: rec {
            awesome = prev.awesome.overrideAttrs (old: rec {
                version = "4.4.0.alpha-h3r3t1c";
                patches = [];
                src = pkgs.fetchFromGitHub {
                    owner = "awesomewm";
                    repo = "awesome";
                    rev = "05a405b38bbcb8fa3b344d45d94d4f56b83c74df";
                    sha256 = "sha256-OBCUbkWEcWHokYNjfz4aRRkxr9rwGNkaKnovzoliFwU=";
                };
            });
            segger-jlink = prev.unstable.segger-jlink.overrideAttrs (old: rec {
                installPhase = ''
                    runHook preInstall
                
                    # Install binaries
                    mkdir -p $out/bin
                    mv J* $out/bin

                    cp $out/bin/JLinkGDBServerCLEXE $out/bin/JLinkGDBServerCL

                    # Install libraries
                    mkdir -p $out/lib
                    mv libjlinkarm.so* $out/lib

                    # This library is opened via dlopen at runtime
                    for libr in $out/lib/*; do
                        ln -s $libr $out/bin
                    done

                    # Install docs and examples
                    mkdir -p $out/share/docs
                    mv Doc/* $out/share/docs
                    mkdir -p $out/share/examples
                    mv Samples/* $out/share/examples
                
                    # Install udev rule
                    mkdir -p $out/lib/udev/rules.d
                    mv 99-jlink.rules $out/lib/udev/rules.d/
                    runHook postInstall
                '';
            });
        };

        packages.x86_64-linux = rec {
            inherit
                (pkgs)
                awesome
                segger-jlink
                ;
        };
    };
}

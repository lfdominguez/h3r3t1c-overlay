{
    description = "My own overlay";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-22.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
        system = "x86_64-linux";

        mynixpkgs-unstable = import nixpkgs-unstable {
            inherit system;

            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;
        };

        overlay-unstable = final: prev: {
            unstable = mynixpkgs-unstable;
        };

        pkgs = import nixpkgs {
            inherit system;

            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;

            overlays = [
                overlay-unstable
                self.overlays.default
            ];
        };
    in {
        overlays.default = final: prev: rec {
            jetbrains-toolbox = pkgs.callPackage ./packages/jetbrains-toolbox {};
            jetbrains-jdk = pkgs.callPackage ./packages/jetbrains-jdk {};
            jetbrains = (pkgs.recurseIntoAttrs (pkgs.callPackages ./packages/jetbrains {
                    vmopts = pkgs.config.jetbrains.vmopts or null;
                    jdk = jetbrains-jdk;
                }) // {
                    jdk = jetbrains-jdk;
                });
            awesome = prev.awesome.overrideAttrs (old: rec {
                version = "master";
                patches = [];
                src = pkgs.fetchFromGitHub {
                    owner = "awesomewm";
                    repo = "awesome";
                    rev = "1239cdf4bc9208f57e4bf018d462c2ee63bf0387";
                    sha256 = "sha256-OBCUbkWEcWHokYNjfz4aRRkxr9rwGNkaKnovzoliFwU=";
                };
            });
            segger-jlink = prev.unstable.segger-jlink.overrideAttrs (old: rec {
                installPhase = ''
                    runHook preInstall
                
                    # Install binaries
                    mkdir -p $out/bin
                    mv J* $out/bin

                    cp $out/bin/JLinkGDBServerCLExe $out/bin/JLinkGDBServerCL

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
                jetbrains
                jetbrains-toolbox
                ;
        };
    };
}

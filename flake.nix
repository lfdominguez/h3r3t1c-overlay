{
    description = "My own overlay";

    inputs = {
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
            cups-brother-hl3150cdn = pkgs.callPackage ./packages/cups/printers/brother/hl3150cdn.nix {};
            libfprint = pkgs.callPackage ./packages/libfprint {};
            mpv-inhibit-gnome = pkgs.callPackage ./packages/mpvScripts/mpv-inhibit-gnome {};
            qtnodeeditor = pkgs.qt6Packages.callPackage ./packages/qt/qnodeeditor {};
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
                cups-brother-hl3150cdn
                segger-jlink
                libfprint
                mpv-inhibit-gnome
                qtnodeeditor
                ;
        };
    };
}

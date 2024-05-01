{
    description = "My own overlay";

    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

        rust-overlay.url = "github:oxalica/rust-overlay";
        pyproject-nix.url = "github:nix-community/pyproject.nix";

        poetry2nix = {
            url = "github:nix-community/poetry2nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, rust-overlay, poetry2nix, pyproject-nix }:
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
                rust-overlay.overlays.default
            ];
        };
    in {
        overlays.default = final: prev: rec {
            copypod = pkgs.callPackage ./packages/copypod { inherit poetry2nix; };
            lightkeeper = pkgs.libsForQt5.callPackage ./packages/lightkeeper {};
            goto = pkgs.callPackage ./packages/goto {};
            cups-brother-hl3150cdn = pkgs.callPackage_i686 ./packages/cups/printers/brother/hl3150cdn.nix {};
            loco-cli = pkgs.callPackage ./packages/loco-cli {};
            clickup = pkgs.callPackage ./packages/clickup {};
            zed = pkgs.callPackage ./packages/zed {};
            nvidia-nemo = pkgs.callPackage ./packages/nvidia-nemo { inherit pyproject-nix; };
            libfprint = pkgs.callPackage ./packages/libfprint {};
            mpv-inhibit-gnome = pkgs.callPackage ./packages/mpvScripts/mpv-inhibit-gnome {};
            qtnodeeditor = pkgs.qt6Packages.callPackage ./packages/qt/qnodeeditor {};
            passbolt-cli = pkgs.callPackage ./packages/passbolt-cli {};
            stable-diffusion-cpp = pkgs.callPackage ./packages/stable-diffusion-cpp {};
            jetbrains = pkgs.callPackage ./packages/jetbrains {
                jdk = pkgs.unstable.jetbrains.jdk;
            };
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
                copypod
                goto
                cups-brother-hl3150cdn
                # segger-jlink
                libfprint
                mpv-inhibit-gnome
                qtnodeeditor
                passbolt-cli
                stable-diffusion-cpp
                jetbrains
                loco-cli
                clickup
                zed
                nvidia-nemo
                lightkeeper
                ;
        };
    };
}

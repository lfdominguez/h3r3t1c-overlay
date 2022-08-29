{
    description = "My own overlay";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-22.05";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
        system = "x86_64-linux";

        overlay-unstable = final: prev: {
            unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };

        pkgs = import nixpkgs {
            inherit system;

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
                };
            });
        };

        packages.x86_64-linux = rec {
            inherit
                (pkgs)
                awesome
                ;
        };
    };
}

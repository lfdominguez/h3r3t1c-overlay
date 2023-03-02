{ lib, stdenv, callPackage, fetchurl, patchelf, makeDesktopItem, zlib, autoPatchelfHook, appimageTools }:

let
  pname = "jetbrains-toolbox";
  version = "1.27.2.13801";
  sha256 = "ece06062a936d0e765ebbdf5d89eb2224cdbaf059a1d8b049a16a6d7f3631275";

in appimageTools.wrapType2 rec {
    inherit pname version;

    name = pname;

    src = stdenv.mkDerivation { 
        name = "${pname}-src";

        src = fetchurl {
            url = "https://download.jetbrains.com/toolbox/${pname}-${version}.tar.gz";
            inherit sha256;
        };

        installPhase = ''
            #mkdir -p $out/bin
            cp jetbrains-toolbox $out
        '';
    };

    extraPkgs = pkgs: with pkgs; [
      libcef
      libsecret
      stdenv.cc.cc.lib
      glibc
      xorg.xcbutilkeysyms
      xorg.libXext
      gcc
      zlib
    ];

    meta = with lib; {
      description = "A toolbox to manage JetBrains products";
      longDescription = ''
      The JetBrains Toolbox lets you install and manage JetBrains Products in muiltiple versions.
      '';
      homepage = "https://www.jetbrains.com/toolbox/";
      platforms = platforms.all;
    };
}

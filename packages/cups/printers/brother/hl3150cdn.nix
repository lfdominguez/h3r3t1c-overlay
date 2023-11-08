{lib, stdenv, fetchurl, cups, dpkg, gnused, makeWrapper, ghostscript, file, a2ps, coreutils, gawk }:

let
  version = "1.1.4-0";
  cupsdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf100434/hl3150cdncupswrapper-${version}.i386.deb";
    sha256 = "e38fdf08a884d48d87d0420c2e21f8a13731356aed34f87bd39281e316577a9f";
  };
  srcdir = "hl3150cdn_cupswrapper_GPL_source_${version}";
  cupssrc = fetchurl {
    url = "https://download.brother.com/welcome/dlf006741/${srcdir}.tar.gz";
    sha256 = "fc8e16c7f2fba75a9826ac727af1eafd86cab7ecbc435f24fad62b9bee3d8ae5";
  };
  lprdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf100432/hl3150cdnlpr-1.1.2-1.i386.deb";
    sha256 = "4a9296d3e503a2e34cacdf22448cfb242ebcaccad68b085d9ff7a7ddbff8bb0d";
  };
in
stdenv.mkDerivation {
  pname = "cups-brother-hl3150cdn";
  inherit version;
  nativeBuildInputs = [ makeWrapper dpkg ];
  buildInputs = [ cups ghostscript a2ps ];

  unpackPhase = ''
    tar -xvf ${cupssrc}
  '';

  buildPhase = ''
    gcc -Wall ${srcdir}/brcupsconfig/brcupsconfig.c -o brcupsconfpt1
  '';

  installPhase = ''
    # install lpr
    dpkg-deb -x ${lprdeb} $out

    substituteInPlace $out/opt/brother/Printers/hl3150cdn/lpd/filterhl3150cdn \
      --replace /opt "$out/opt"
    substituteInPlace $out/opt/brother/Printers/hl3150cdn/inf/setupPrintcapij \
      --replace /opt "$out/opt"

    sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' $out/opt/brother/Printers/hl3150cdn/lpd/psconvertij2

    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux.so.2 $out/opt/brother/Printers/hl3150cdn/lpd/brhl3150cdnfilter
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux.so.2 $out/usr/bin/brprintconf_hl3150cdn

    wrapProgram $out/opt/brother/Printers/hl3150cdn/lpd/psconvertij2 \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }

    wrapProgram $out/opt/brother/Printers/hl3150cdn/lpd/filterhl3150cdn \
      --prefix PATH ":" ${ lib.makeBinPath [ ghostscript a2ps file gnused coreutils ] }


    dpkg-deb -x ${cupsdeb} $out

    substituteInPlace $out/opt/brother/Printers/hl3150cdn/cupswrapper/cupswrapperhl3150cdn \
      --replace /opt "$out/opt"

    mkdir -p $out/lib/cups/filter
    ln -s $out/opt/brother/Printers/hl3150cdn/cupswrapper/cupswrapperhl3150cdn $out/lib/cups/filter/cupswrapperhl3150cdn

    ln -s $out/opt/brother/Printers/hl3150cdn/cupswrapper/brother_hl3150cdn_printer_en.ppd $out/lib/cups/filter/brother_hl3150cdn_printer_en.ppd

    cp brcupsconfpt1 $out/opt/brother/Printers/hl3150cdn/cupswrapper/
    ln -s $out/opt/brother/Printers/hl3150cdn/cupswrapper/brcupsconfpt1 $out/lib/cups/filter/brcupsconfpt1
    ln -s $out/opt/brother/Printers/hl3150cdn/lpd/filterhl3150cdn $out/lib/cups/filter/brother_lpdwrapper_hl3150cdn

    wrapProgram $out/opt/brother/Printers/hl3150cdn/cupswrapper/cupswrapperhl3150cdn \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }
  '';

  meta = {
    homepage = "http://www.brother.com/";
    description = "Brother hl3150cdn printer driver";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=eu_ot&lang=en&prod=hl3150cdn_us_eu&os=128";
  };
}

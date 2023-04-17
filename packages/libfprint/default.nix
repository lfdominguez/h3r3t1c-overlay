{ lib, stdenv
, fetchFromGitHub
, pkg-config
, meson
, python3
, ninja
, gusb
, pixman
, glib
, nss
, gobject-introspection
, coreutils
, cairo
, libgudev
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
}:

stdenv.mkDerivation rec {
  pname = "libfprint";
  version = "1.94.5-lenovo";
  outputs = [ "out" "devdoc" ];

  src = fetchFromGitHub {
    owner = "lfdominguez";
    repo = "libfprint";
    rev = "d60b4eec7e8e91308990516c9e7dc8fb19682173";
    sha256 = "sha256-mldk5yuUrO/7oj/GtYl/t16pMSHO1oeCkMEX26khXSo=";
  };

  postPatch = ''
    patchShebangs \
      tests/test-runner.sh \
      tests/unittest_inspector.py \
      tests/virtual-image.py \
      tests/umockdev-test.py \
      tests/test-generated-hwdb.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
  ];

  buildInputs = [
    gusb
    pixman
    glib
    nss
    cairo
    libgudev
  ];

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    # Include virtual drivers for fprintd tests
    "-Ddrivers=all"
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  installCheckInputs = [
    (python3.withPackages (p: with p; [ pygobject3 ]))
  ];

  # We need to run tests _after_ install so all the paths that get loaded are in
  # the right place.
  doCheck = false;

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    ninjaCheckPhase

    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://fprint.freedesktop.org/";
    description = "A library designed to make it easy to add support for consumer fingerprint readers. Changed to touch sensor on Lenovo ELAN device";
    license = licenses.lgpl21Only;
    platforms = platforms.linux;
  };
}

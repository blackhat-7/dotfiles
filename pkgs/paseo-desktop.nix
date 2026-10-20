{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libsecret,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "paseo-desktop";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/getpaseo/paseo/releases/download/v${finalAttrs.version}/Paseo-${finalAttrs.version}-amd64.deb";
    hash = "sha256-O7dBhJuWHSUesQeYTIlLTdATSKWTQ+nXsQW56yLg924=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib # sherpa-onnx native modules
    (lib.getLib systemd) # libudev
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];

  runtimeDependencies = [ libglvnd ];

  # The upstream launcher script picks the sandbox mode (user namespaces or
  # --no-sandbox); a setuid chrome-sandbox cannot ship in the Nix store.
  # app-update.yml drives the in-app deb updater, which cannot write the store.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt usr/share $out/

    rm -f $out/opt/Paseo/chrome-sandbox $out/opt/Paseo/resources/app-update.yml
    find $out/opt/Paseo -name '*musl*.node' -delete

    install -Dm755 /dev/null $out/bin/paseo-desktop
    cat > $out/bin/paseo-desktop <<WRAPPER
    #!${stdenv.shell}
    exec $out/opt/Paseo/Paseo "\$@"
    WRAPPER

    substituteInPlace $out/share/applications/Paseo.desktop \
      --replace-fail "Exec=/opt/Paseo/Paseo" "Exec=$out/bin/paseo-desktop"

    runHook postInstall
  '';

  meta = {
    description = "Paseo desktop app";
    homepage = "https://paseo.sh";
    license = lib.licenses.asl20;
    mainProgram = "paseo-desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

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
  pname = "claude-desktop";
  version = "2.7032.0";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-Hn9FBLylsvay08QSPRRdcnZH538u4tBGhQcR5h59exE=";
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
    (lib.getLib systemd) # libudev
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];

  # The Electron bundle dlopens GL/EGL and the chrome-sandbox helper needs a
  # setuid root binary that Nix cannot ship, so run the namespace sandbox instead.
  runtimeDependencies = [ libglvnd ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib usr/share $out/

    install -Dm755 /dev/null $out/bin/claude-desktop
    cat > $out/bin/claude-desktop <<WRAPPER
    #!${stdenv.shell}
    exec $out/lib/claude-desktop/claude-desktop "\$@"
    WRAPPER

    rm -f $out/lib/claude-desktop/chrome-sandbox
    rm -rf $out/share/lintian

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai/download";
    license = lib.licenses.unfree;
    mainProgram = "claude-desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

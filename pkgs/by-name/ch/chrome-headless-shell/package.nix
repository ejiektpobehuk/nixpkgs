{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  patchelfUnstable,

  # Runtime dependencies (verified against ELF NEEDED of all bundled binaries)
  alsa-lib,
  at-spi2-atk,
  dbus,
  expat,
  glib,
  libgbm,
  libgcc,
  libX11,
  libxcb,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libxkbcommon,
  libXrandr,
  nspr,
  nss,
  systemdLibs, # libudev
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chrome-headless-shell";
  version = "147.0.7695.0";

  src = fetchzip {
    url = "https://storage.googleapis.com/chrome-for-testing-public/${finalAttrs.version}/linux64/chrome-headless-shell-linux64.zip";
    hash = "sha256-99Bw33MlTieKtKiVcFA796mdGsA47umcde7cNbfj04o=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    dbus
    expat
    glib
    libgbm
    libgcc.lib
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libxkbcommon
    libXrandr
    nspr
    nss
    systemdLibs
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/chrome-headless-shell $out/bin

    cp -a . $out/lib/chrome-headless-shell/

    # chromedp (Go Chrome DevTools Protocol library) searches PATH for
    # "headless-shell" and "headless_shell" before other browser names.
    # Symlinks resolve $ORIGIN RPATH relative to the real binary, not the link.
    ln -s $out/lib/chrome-headless-shell/chrome-headless-shell $out/bin/chrome-headless-shell
    ln -s $out/lib/chrome-headless-shell/chrome-headless-shell $out/bin/headless-shell

    runHook postInstall
  '';

  meta = {
    description = "Headless shell for Chrome, for automating and testing web pages";
    homepage = "https://developer.chrome.com/blog/chrome-headless-shell";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      ejiektpobehuk
      wrbbz
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "chrome-headless-shell";
  };
})

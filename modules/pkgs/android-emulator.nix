{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "37.2.8";
  pname = "android-emulator";

  # Download standalone Android emulator package from Google
  emulator-src = pkgs.fetchurl {
    url = "https://dl.google.com/android/repository/emulator-linux_x64-16259959.zip";
    # To replace with fake hash if desired: lib.fakeHash
    hash = "sha256-AuG+3w92iksbH9yIkZNOSCxv+BqVh7Xh8mzNWkv4JTU=";
  };

  emulator-unpacked = pkgs.stdenv.mkDerivation {
    pname = "${pname}-unpacked";
    inherit version;
    src = emulator-src;

    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/android-sdk
      cp -r emulator $out/libexec/android-sdk/
      runHook postInstall
    '';
  };

in
pkgs.buildFHSEnv {
  name = "emulator";

  targetPkgs = pkgs: with pkgs; [
    glibc
    libGL
    libpulseaudio
    alsa-lib
    nss
    nspr
    expat
    freetype
    libdrm
    libpng
    libuuid
    libbsd
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrender
    libxtst
    libxkbfile
    libxshmfence
    libxkbcommon
    wayland
    dbus
    systemd
    zlib
    fontconfig
    vulkan-loader
  ];

  runScript = pkgs.writeShellScript "emulator-run" ''
    export ANDROID_HOME="''${ANDROID_HOME:-$HOME/Android/Sdk}"
    export ANDROID_SDK_ROOT="''${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
    export ANDROID_AVD_HOME="''${ANDROID_AVD_HOME:-$HOME/.android/avd}"

    binary=$(basename "$0")
    case "$binary" in
      emulator-check)
        exec ${emulator-unpacked}/libexec/android-sdk/emulator/emulator-check "$@"
        ;;
      mksdcard)
        exec ${emulator-unpacked}/libexec/android-sdk/emulator/mksdcard "$@"
        ;;
      *)
        exec ${emulator-unpacked}/libexec/android-sdk/emulator/emulator "$@"
        ;;
    esac
  '';

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/android-emulator.desktop <<EOF
[Desktop Entry]
Name=Android Emulator
Comment=Android Virtual Device Emulator
Exec=$out/bin/emulator
Icon=android
Terminal=false
Type=Application
Categories=Development;
EOF

    ln -s emulator $out/bin/android-emulator
    ln -s emulator $out/bin/emulator-check
    ln -s emulator $out/bin/mksdcard
  '';

  meta = with lib; {
    description = "Standalone Android Emulator from Google";
    homepage = "https://developer.android.com/studio/run/emulator";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "emulator";
  };
}

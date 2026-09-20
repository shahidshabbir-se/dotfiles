{
  pkgs,
}:

pkgs.buildFHSEnv {
  name = "emulator";

  targetPkgs =
    pkgs: with pkgs; [
      glibc
      gcc.cc
      libgcc
      zlib

      libx11
      libxcb
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxcomposite
      libxcursor
      libxdamage
      libxinerama
      libxkbcommon
      libxshmfence
      libxscrnsaver
      libxtst

      libGL
      mesa
      libdrm
      vulkan-loader

      alsa-lib
      libpulseaudio

      glib
      gtk3
      pango
      cairo
      gdk-pixbuf
      atk
      at-spi2-atk
      at-spi2-core

      nss
      nspr
      openssl
      curl

      libpng
      libjpeg
      libwebp
      expat
      bzip2
      xz
      zstd

      dbus
      dbus-glib
      fontconfig
      freetype
      libuuid
      libsecret

      bash
      coreutils
      findutils
      gnugrep
      procps
      which
      file
    ];

  multiPkgs =
    pkgs: with pkgs; [
      glibc
      gcc.cc
      libgcc
      zlib

      libx11
      libxcb
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxcomposite
      libxcursor
      libxdamage
      libxinerama
      libxkbcommon
      libxshmfence
      libxtst

      libGL
      mesa
      libdrm
      vulkan-loader

      alsa-lib
      libpulseaudio

      glib
      gtk3
      pango
      cairo
      gdk-pixbuf
      atk
      at-spi2-atk
      at-spi2-core

      nss
      nspr
      openssl
      curl

      libpng
      libjpeg
      libwebp
      expat

      dbus
      dbus-glib

      fontconfig
      freetype
    ];

  runScript = pkgs.writeShellScript "emulator" ''
    set -euo pipefail

    export ANDROID_HOME="''${ANDROID_HOME:-$HOME/Android/Sdk}"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export ANDROID_EMULATOR_HOME="''${ANDROID_EMULATOR_HOME:-$HOME/.android}"
    export ANDROID_AVD_HOME="''${ANDROID_AVD_HOME:-$HOME/.android/avd}"

    export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

    export LD_LIBRARY_PATH="$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib:$ANDROID_HOME/emulator/lib:$ANDROID_HOME/emulator/qemu/linux-x86_64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    export QT_X11_NO_MITSHM=1
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"

    exec "$ANDROID_HOME/emulator/emulator" "$@"
  '';
}

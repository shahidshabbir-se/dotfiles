{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  glib,
  gdk-pixbuf,
  cairo,
  desktop-file-utils,
  appstream-glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swash";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "ItsLemmy";
    repo = "swash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SxdrsKUIDLUfWQp7Wa50NwFo36h3LzMd6SOBIy14KAA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    appstream-glib
    glib
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    gdk-pixbuf
    cairo
  ];

  meta = {
    description = "Fast screenshot annotator and lightweight image editor";
    homepage = "https://github.com/ItsLemmy/swash";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "swash";
  };
})

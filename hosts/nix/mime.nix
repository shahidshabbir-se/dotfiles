{
  browserDesktopFile,
  imageViewerDesktopFile,
  fileManagerDesktopFile,
}:
{ lib, ... }:
let
  browserMimeTypes = [
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/chrome"
    "text/html"
    "text/markdown"
    "text/x-markdown"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/xhtml+xml"
    "application/x-extension-xhtml"
    "application/x-extension-xht"
    "application/pdf"
    "application/json"
  ];

  imageMimeTypes = [
    "image/png"
    "image/jpeg"
    "image/gif"
    "image/webp"
    "image/bmp"
    "image/svg+xml"
    "image/tiff"
    "image/avif"
    "image/heic"
  ];

  fileManagerMimeTypes = [
    "inode/directory"
    "inode/mount-point"
    "x-directory/normal"
  ];

  mimeDefaultApplications =
    lib.genAttrs browserMimeTypes (_: [ browserDesktopFile ])
    // lib.genAttrs imageMimeTypes (_: [ imageViewerDesktopFile ])
    // lib.genAttrs fileManagerMimeTypes (_: [ fileManagerDesktopFile ]);
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = mimeDefaultApplications;
  };
}

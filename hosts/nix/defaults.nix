{ pkgs, device }:
let
  username = "shahid";
  paths = rec {
    home = "/home/${username}";
    workspace = "${home}/Projects";
    dotfiles = "${home}/dotfiles";
  };

  apps = rec {
    browser = "zen-beta";
    browserDesktopFile = "${browser}.desktop";
    imageViewerDesktopFile = "org.gnome.gThumb.desktop";
    fileManagerDesktopFile = "org.gnome.Nautilus.desktop";
  };

  gtkThemePackage = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" ];
    size = "standard";
  };
in
{
  inherit
    username
    paths
    apps
    gtkThemePackage
    ;
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";

  theme = {
    gtk = "catppuccin-mocha-blue-standard";
    icons = "Papirus-Dark";
    font = "SF Pro Display 10";
    monospaceFont = "SpaceMono Nerd Font 10";
  };

  cursor = {
    name = "Qogir";
    size = if device.type == "laptop" then 36 else 24;
    package = pkgs.qogir-icon-theme;
  };
}

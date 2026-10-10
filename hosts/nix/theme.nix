{ theme, gtkThemePackage }:
{ pkgs, ... }:
{
  # Libadwaita and GTK applications use this preference for dark mode.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Home Manager links icon themes but not GTK themes, so publish the GTK theme
  # explicitly. Without this symlink GTK silently falls back to a default theme,
  # which ignores the accent colour set above.
  xdg.dataFile."themes/${theme.gtk}" = {
    source = "${gtkThemePackage}/share/themes/${theme.gtk}";
    recursive = true;
  };
  xdg.dataFile."themes/${theme.gtk}-hdpi" = {
    source = "${gtkThemePackage}/share/themes/${theme.gtk}-hdpi";
    recursive = true;
  };
  xdg.dataFile."themes/${theme.gtk}-xhdpi" = {
    source = "${gtkThemePackage}/share/themes/${theme.gtk}-xhdpi";
    recursive = true;
  };

  gtk = {
    enable = true;

    theme = {
      name = theme.gtk;
      package = gtkThemePackage;
    };

    iconTheme = {
      name = theme.icons;
      package = pkgs.catppuccin-papirus-folders;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}

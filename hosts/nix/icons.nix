{
  homeDirectory,
  workspaceDirectory,
  dotfilesDirectory,
}:
{ pkgs, lib, ... }:
let
  gtkBookmarks = ''
    file://${homeDirectory}/Desktop Desktop
    file://${homeDirectory}/Documents Documents
    file://${dotfilesDirectory} Dotfiles
    file://${homeDirectory}/Downloads Downloads
    file://${homeDirectory}/Extras Extras
    file://${homeDirectory}/Music Music
    file://${homeDirectory}/Pictures Pictures
    file://${workspaceDirectory} Projects
    file://${homeDirectory}/Videos Videos
  '';

  # Nautilus 50 treats file:// SVG custom-icon as a document. Use themed names.
  folderIconEntries = [
    {
      path = "${homeDirectory}/Desktop";
      name = "user-desktop";
      symbolic = "user-desktop-symbolic";
    }
    {
      path = "${homeDirectory}/Documents";
      name = "folder-documents";
      symbolic = "folder-documents";
    }
    {
      path = dotfilesDirectory;
      name = "folder-git";
      symbolic = "folder-git";
    }
    {
      path = "${homeDirectory}/Downloads";
      name = "folder-download";
      symbolic = "folder-download-symbolic";
    }
    {
      path = "${homeDirectory}/Extras";
      name = "folder-applications";
      symbolic = "folder-applications";
    }
    {
      path = "${homeDirectory}/Games";
      name = "folder-games";
      symbolic = "folder-games";
    }
    {
      path = "${homeDirectory}/Music";
      name = "folder-music";
      symbolic = "folder-music-symbolic";
    }
    {
      path = "${homeDirectory}/Pictures";
      name = "folder-pictures";
      symbolic = "folder-pictures-symbolic";
    }
    {
      path = workspaceDirectory;
      name = "folder-code";
      symbolic = "folder-code";
    }
    {
      path = "${homeDirectory}/Storage";
      name = "folder-sync";
      symbolic = "folder-sync";
    }
    {
      path = "${homeDirectory}/Public";
      name = "folder-publicshare";
      symbolic = "folder-publicshare-symbolic";
    }
    {
      path = "${homeDirectory}/Templates";
      name = "folder-templates";
      symbolic = "folder-templates-symbolic";
    }
    {
      path = "${homeDirectory}/Videos";
      name = "folder-videos";
      symbolic = "folder-videos-symbolic";
    }
  ];

  setNautilusFolderIconsScript = ''
    set_folder_icon() {
      folder="$1"
      icon_name="$2"

      [ -d "$folder" ] || return 0

      ${pkgs.glib}/bin/gio set -t unset "$folder" metadata::custom-icon 2>/dev/null || true
      ${pkgs.glib}/bin/gio set -t string "$folder" metadata::custom-icon-name "$icon_name" 2>/dev/null || true
    }

    ${lib.concatMapStringsSep "\n" (e: ''
      set_folder_icon "${e.path}" "${e.name}"
    '') folderIconEntries}
  '';

  nautilusBookmarkIcons =
    let
      inherit (lib.hm.gvariant) mkArray mkDictionaryEntry type;
    in
    mkArray
      (type.dictionaryEntryOf [
        type.string
        type.string
      ])
      (
        map (
          e:
          mkDictionaryEntry [
            "file://${e.path}"
            e.symbolic
          ]
        ) folderIconEntries
      );
in
{
  home.activation.setNautilusFolderIcons = lib.hm.dag.entryAfter [
    "writeBoundary"
    "createProjectsWorkspace"
  ] setNautilusFolderIconsScript;

  xdg.configFile = {
    "gtk-3.0/bookmarks".text = gtkBookmarks;
    "gtk-4.0/bookmarks".text = gtkBookmarks;
  };

  dconf.settings."io/github/yannmasoch/nautilus-my-computer" = {
    custom-bookmark-icons = nautilusBookmarkIcons;
    preferred-folders = [
      "home"
      "documents"
      "downloads"
      "file://~/Extras"
      "music"
      "pictures"
      "file://~/Projects"
      "starred"
      "videos"
    ];
  };
}

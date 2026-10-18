{ lib, ... }:

let
  layerRuleNamespaces = [
    "logout_dialog"
    "qs-bar"
    "qs-launcher"
    "qs-lockfade"
    "qs-notify"
    "qs-nowplaying"
    "qs-osd"
    "qs-passprompt"
    "qs-pet"
    "qs-theme"
    "qs-toasts"
    "qs-wifi"
    "vicinae"
  ];

  layerRuleNoAnimNamespaces = [ "logout_dialog" "vicinae" ];

  blurLayerRule = namespace: {
    name = "blur-${lib.replaceStrings [ "_" ":" ] [ "-" "-" ] namespace}";
    match.namespace = namespace;
    blur = true;
    ignore_alpha = if namespace == "qs-bar" then 0.5 else 0.2;
  };

  noAnimLayerRule = namespace: {
    name = "no-anim-${lib.replaceStrings [ "_" ] [ "-" ] namespace}";
    match.namespace = namespace;
    no_anim = true;
  };

  appClass = "^(zen|google-chrome|Chrome|chromium|Chromium|Cursor|code|Code|obsidian|discord|slack|Spotify|ChatGPT|chatgpt)$";
  fullOpacity = "1.00 override 1.00 override 1.00 override";

  windowRules = [
    { name = "yazi-float"; match.title = "^(yazi)$"; float = true; }
    { name = "yazi-size"; match.title = "^(yazi)$"; size = "800 500"; }
    { name = "yazi-center"; match.title = "^(yazi)$"; center = true; }

    { name = "nautilus-float"; match.class = "^(org.gnome.Nautilus|Nautilus|nautilus)$"; float = true; }
    { name = "nautilus-size"; match.class = "^(org.gnome.Nautilus|Nautilus|nautilus)$"; size = "1100 700"; }
    { name = "nautilus-center"; match.class = "^(org.gnome.Nautilus|Nautilus|nautilus)$"; center = true; }

    { name = "cosmic-files-float"; match.class = "^(com\\.system76\\.CosmicFiles)$"; float = true; }
    { name = "cosmic-files-size"; match.class = "^(com\\.system76\\.CosmicFiles)$"; size = "1100 700"; }
    { name = "cosmic-files-center"; match.class = "^(com\\.system76\\.CosmicFiles)$"; center = true; }
    { name = "cosmic-files-undecorated"; match.class = "^(com\\.system76\\.CosmicFiles)$"; decorate = false; }

    { name = "gthumb-float"; match.class = "^(gthumb|org\\.gnome\\.gThumb)$"; float = true; }
    { name = "gthumb-size"; match.class = "^(gthumb|org\\.gnome\\.gThumb)$"; size = "1200 800"; }
    { name = "gthumb-center"; match.class = "^(gthumb|org\\.gnome\\.gThumb)$"; center = true; }

    { name = "swash-float"; match.class = "^(dev\\.lemmy\\.swash)$"; float = true; }
    { name = "swash-size"; match.class = "^(dev\\.lemmy\\.swash)$"; size = "1400 900"; }
    { name = "swash-center"; match.class = "^(dev\\.lemmy\\.swash)$"; center = true; }

    { name = "screenshot-float"; match.class = "^(qs-screenshot-rec)$"; float = true; }
    { name = "screenshot-size"; match.class = "^(qs-screenshot-rec)$"; size = "1280 720"; }
    { name = "screenshot-center"; match.class = "^(qs-screenshot-rec)$"; center = true; }

    { name = "waysend-class-workspace"; match.class = "^(waysend|WaySend)$"; workspace = "special:magic silent"; }
    { name = "waysend-title-workspace"; match.title = "^(WaySend)$"; workspace = "special:magic silent"; }
    { name = "brave-no-blur"; match.class = "^(Brave-browser)$"; no_blur = true; }
    { name = "emulator-float"; match.class = "^(Emulator)$"; float = true; }
    { name = "emulator-no-blur"; match.class = "^(Emulator)$"; no_blur = true; }
    { name = "apps-no-blur"; match.class = appClass; no_blur = true; }
    { name = "apps-full-opacity"; match.class = appClass; opacity = fullOpacity; }

    { name = "btop-float"; match.title = "^(btop)$"; float = true; }
    { name = "btop-size"; match.title = "^(btop)$"; size = "1280 800"; }
    { name = "btop-center"; match.title = "^(btop)$"; center = true; }

    { name = "podman-tui-float"; match.class = "^(podman-tui)$"; float = true; }
    { name = "podman-tui-size"; match.class = "^(podman-tui)$"; size = "1000 600"; }
    { name = "podman-tui-center"; match.class = "^(podman-tui)$"; center = true; }

    { name = "ghostty-fullscreen-opacity"; match.class = "^(com.mitchellh.ghostty)$"; match.fullscreen = 1; opacity = fullOpacity; }
    { name = "ghostty-fullscreen-rgbx"; match.class = "^(com.mitchellh.ghostty)$"; match.fullscreen = 1; force_rgbx = true; }
    { name = "suppress-maximize"; match.class = ".*"; suppress_event = "maximize"; }
    {
      name = "no-focus-empty-xwayland";
      match = {
        class = "^$";
        title = "^$";
        xwayland = true;
        float = true;
        fullscreen = false;
      };
      no_focus = true;
    }
  ];
in
{
  wayland.windowManager.hyprland.settings = {
    window_rule = windowRules;
    layer_rule =
      map blurLayerRule layerRuleNamespaces
      ++ map noAnimLayerRule layerRuleNoAnimNamespaces;
  };
}

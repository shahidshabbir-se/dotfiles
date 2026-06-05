{
  config,
  pkgs,
  ...
}:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  homeDirectory = config.home.homeDirectory;

  wlogoutPointer = pkgs.wlogout.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
            ${pkgs.python3}/bin/python3 - <<'PY'
      from pathlib import Path

      path = Path("main.c")
      data = path.read_text()

      old = """static gboolean background_clicked(GtkWidget *widget, GdkEventButton event,
                                         gpointer user_data)
      {
          for (int i = 0; i < num_of_monitors; i++)
          {
              if (i != primary_monitor)
              {
                  gtk_widget_destroy(GTK_WIDGET(window[i]));
              }
          }
          gtk_main_quit();
          return TRUE;
      }

      static char *get_substring(char *s, int start, int end, char *buf)
      """

      new = """static gboolean background_clicked(GtkWidget *widget, GdkEventButton event,
                                         gpointer user_data)
      {
          for (int i = 0; i < num_of_monitors; i++)
          {
              if (i != primary_monitor)
              {
                  gtk_widget_destroy(GTK_WIDGET(window[i]));
              }
          }
          gtk_main_quit();
          return TRUE;
      }

      static gboolean button_enter(GtkWidget *widget, GdkEventCrossing *event,
                                   gpointer user_data)
      {
          GtkWidget *toplevel = gtk_widget_get_toplevel(widget);
          GdkWindow *window = gtk_widget_get_window(toplevel);
          GdkCursor *cursor = gdk_cursor_new_from_name(gdk_display_get_default(), "pointer");

          if (!cursor)
          {
              cursor = gdk_cursor_new_from_name(gdk_display_get_default(), "hand2");
          }

          if (window && cursor)
          {
              gdk_window_set_cursor(window, cursor);
          }

          if (cursor)
          {
              g_object_unref(cursor);
          }

          return FALSE;
      }

      static gboolean button_leave(GtkWidget *widget, GdkEventCrossing *event,
                                   gpointer user_data)
      {
          GtkWidget *toplevel = gtk_widget_get_toplevel(widget);
          GdkWindow *window = gtk_widget_get_window(toplevel);

          if (window)
          {
              gdk_window_set_cursor(window, NULL);
          }

          return FALSE;
      }

      static char *get_substring(char *s, int start, int end, char *buf)
      """

      old2 = """            g_signal_connect(but[i][j], \"clicked\", G_CALLBACK(execute),
                                   buttons[count].action);
                  gtk_widget_set_hexpand(but[i][j], TRUE);
                  gtk_widget_set_vexpand(but[i][j], TRUE);
      """

      new2 = """            g_signal_connect(but[i][j], \"clicked\", G_CALLBACK(execute),
                                   buttons[count].action);
                  gtk_widget_add_events(but[i][j], GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK);
                  g_signal_connect(but[i][j], \"enter-notify-event\", G_CALLBACK(button_enter), NULL);
                  g_signal_connect(but[i][j], \"leave-notify-event\", G_CALLBACK(button_leave), NULL);
                  gtk_widget_set_hexpand(but[i][j], TRUE);
                  gtk_widget_set_vexpand(but[i][j], TRUE);
      """

      if old not in data:
          raise SystemExit("failed to patch wlogout main.c: anchor 1 not found")
      if old2 not in data:
          raise SystemExit("failed to patch wlogout main.c: anchor 2 not found")

      data = data.replace(old, new, 1)
      data = data.replace(old2, new2, 1)
      path.write_text(data)
      PY
    '';
  });

  wlogoutLaunch = pkgs.writeShellScript "wlogout-launch.sh" ''
        set -euo pipefail

        if pgrep -x wlogout >/dev/null; then
          pkill -x wlogout
          exit 0
        fi

        conf_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/wlogout"
        layout="$conf_dir/layout"
        template="$conf_dir/style.css"
        colors="$conf_dir/colors.css"

        mkdir -p "$conf_dir"

        if [[ ! -f "$colors" ]]; then
          cat > "$colors" <<'EOF'
    /* wlogout colors fallback */
    @define-color main-bg alpha(#20243a, 0.88);
    @define-color wb-act-bg alpha(#b17ea7, 0.60);
    @define-color wb-hvr-bg alpha(#c08cb5, 0.72);
    EOF
        fi

        monitor_json="$(hyprctl -i 0 -j monitors 2>/dev/null || true)"

        if printf '%s' "$monitor_json" | jq -e . >/dev/null 2>&1; then
          x_mon="$(printf '%s' "$monitor_json" | jq -r 'first(.[] | select(.focused==true) | .width) // first(.[] | .width) // 1920')"
          y_mon="$(printf '%s' "$monitor_json" | jq -r 'first(.[] | select(.focused==true) | .height) // first(.[] | .height) // 1080')"
          scale_raw="$(printf '%s' "$monitor_json" | jq -r 'first(.[] | select(.focused==true) | .scale) // first(.[] | .scale) // 1')"
        else
          x_mon=1920
          y_mon=1080
          scale_raw=1
        fi

        hypr_scale="$(printf '%s' "$scale_raw" | tr -d '.')"
        hypr_scale=''${hypr_scale:-10}

        wl_cols=6
        export mgn=$((y_mon * 28 / hypr_scale))
        export hvr=$((y_mon * 23 / hypr_scale))
        export fntSize=$((y_mon * 2 / 100))
        export BtnCol="white"
        export active_rad=40
        export button_rad=64

        rendered_css="$(${pkgs.python3}/bin/python3 - "$template" <<'PY'
    import os
    import sys

    template_path = sys.argv[1]
    with open(template_path, 'r', encoding='utf-8') as f:
        data = f.read()

    print(os.path.expandvars(data), end="")
    PY
        )"

        wlogout \
          --layout "$layout" \
          --css <(printf '%s\n' "$rendered_css") \
          -b "$wl_cols" -c 0 -r 0 -m 0 \
          --protocol layer-shell
  '';

  wlogoutHibernate = pkgs.writeShellScript "wlogout-hibernate-hdr.sh" ''
    set -euo pipefail

    ${pkgs.systemd}/bin/systemctl hibernate

    for delay in 1 2 3; do
      ${pkgs.coreutils}/bin/sleep "$delay"
      if ${pkgs.hyprland}/bin/hyprctl -i 0 reload >/dev/null 2>&1; then
        exit 0
      fi
    done

    printf '%s\n' 'failed to reload Hyprland after hibernate' >&2
    exit 1
  '';
in
{
  home.packages = [ wlogoutPointer ];

  xdg.configFile = {
    "wlogout/layout".text = ''
      {
          "label": "lock",
          "action": "sh $HOME/.config/lock-screen/lock.sh",
          "text": "Lock",
          "keybind": "l"
      }

      {
          "label": "logout",
          "action": "hyprctl dispatch exit",
          "text": "Logout",
          "keybind": "e"
      }

      {
          "label": "suspend",
          "action": "sh $HOME/.config/lock-screen/lock.sh & disown && systemctl suspend",
          "text": "Suspend",
          "keybind": "u"
      }

      {
          "label": "shutdown",
          "action": "systemctl poweroff",
          "text": "Shutdown",
          "keybind": "s"
      }

      {
          "label": "hibernate",
          "action": "${wlogoutHibernate}",
          "text": "Hibernate",
          "keybind": "h"
      }

      {
          "label": "reboot",
          "action": "systemctl reboot",
          "text": "Reboot",
          "keybind": "r"
      }
    '';

    "wlogout/style.css".text = ''
      * {
          background-image: none;
          font-size: ''${fntSize}px;
          font-family: "Rubik", "SF Pro Display", sans-serif;
      }

      @define-color main-bg rgba(32,36,58,0.88);
      @define-color wb-act-bg rgba(177,126,167,0.60);
      @define-color wb-hvr-bg rgba(192,140,181,0.72);

      @import "$HOME/.config/wlogout/colors.css";

      @keyframes gradient_f {
        0% { opacity: 1; }
        100% { opacity: 1; }
      }

      window {
          background-color: transparent;
      }

      button {
          color: ''${BtnCol};
          background-color: alpha(@main-bg, 0.38);
          outline-style: none;
          border: none;
          border-width: 0px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 20%;
          border-radius: 0px;
          box-shadow: none;
          text-shadow: none;
          animation: gradient_f 20s ease-in infinite;
      }

      button:focus {
          background-color: @wb-act-bg;
          background-size: 30%;
      }

      button:hover {
          background-color: @wb-hvr-bg;
          background-size: 40%;
          border-radius: ''${active_rad}px;
          animation: gradient_f 20s ease-in infinite;
          transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
      }

      button:hover#lock {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px 0px ''${hvr}px ''${mgn}px;
      }

      button:hover#logout {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px 0px ''${hvr}px 0px;
      }

      button:hover#suspend {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px 0px ''${hvr}px 0px;
      }

      button:hover#shutdown {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px 0px ''${hvr}px 0px;
      }

      button:hover#hibernate {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px 0px ''${hvr}px 0px;
      }

      button:hover#reboot {
          border-radius: ''${active_rad}px;
          margin: ''${hvr}px ''${mgn}px ''${hvr}px 0px;
      }

      #lock {
          background-image: image(url("$HOME/.config/wlogout/icons/lock_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/lock_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/lock.png"));
          border-radius: ''${button_rad}px 0px 0px ''${button_rad}px;
          margin: ''${mgn}px 0px ''${mgn}px ''${mgn}px;
      }

      #logout {
          background-image: image(url("$HOME/.config/wlogout/icons/logout_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/logout_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/logout.png"));
          border-radius: 0px 0px 0px 0px;
          margin: ''${mgn}px 0px ''${mgn}px 0px;
      }

      #suspend {
          background-image: image(url("$HOME/.config/wlogout/icons/suspend_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/suspend_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/suspend.png"));
          border-radius: 0px 0px 0px 0px;
          margin: ''${mgn}px 0px ''${mgn}px 0px;
      }

      #shutdown {
          background-image: image(url("$HOME/.config/wlogout/icons/shutdown_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/shutdown_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/shutdown.png"));
          border-radius: 0px 0px 0px 0px;
          margin: ''${mgn}px 0px ''${mgn}px 0px;
      }

      #hibernate {
          background-image: image(url("$HOME/.config/wlogout/icons/hibernate_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/hibernate_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/hibernate.png"));
          border-radius: 0px 0px 0px 0px;
          margin: ''${mgn}px 0px ''${mgn}px 0px;
      }

      #reboot {
          background-image: image(url("$HOME/.config/wlogout/icons/reboot_''${BtnCol}.png"), url("${homeDirectory}/.config/wlogout/icons/reboot_''${BtnCol}.png"), url("${wlogoutPointer}/share/wlogout/icons/reboot.png"));
          border-radius: 0px ''${button_rad}px ''${button_rad}px 0px;
          margin: ''${mgn}px ''${mgn}px ''${mgn}px 0px;
      }
    '';

    "wlogout/launch.sh".source = wlogoutLaunch;
    "wlogout/icons".source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/assets/wlogout-icons";
  };
}

{ ... }:

{
  enable = true;

  # Use matugen-generated config for dynamic wallpaper-based colors
  # Fallback settings below are written to dunstrc but dunst reads configFile instead
  configFile = "/home/shahid/dotfiles/config/dunst/dunstrc";

  settings = {
    global = {
      # ───────────────────────────────────────────────
      # Position & Layout
      # ───────────────────────────────────────────────
      monitor = 0;
      follow = "mouse";
      origin = "top-right";
      offset = "20x60";
      width = "(300, 400)";
      scale = 0;
      notification_limit = 20;
      indicate_hidden = true;

      # ───────────────────────────────────────────────
      # Appearance (gh0stzk style)
      # ───────────────────────────────────────────────
      transparency = 0;
      corner_radius = 6;
      gap_size = 4;
      separator_height = 1;
      separator_color = "#abb2bf";
      padding = 15;
      horizontal_padding = 15;
      text_icon_padding = 0;
      frame_width = 0;
      frame_color = "#222330";

      # ───────────────────────────────────────────────
      # Typography
      # ───────────────────────────────────────────────
      font = "JetBrainsMono NF Medium 9";
      line_height = 0;
      markup = "full";
      format = "<span size='xx-large' font_desc='JetBrainsMono NF 9' weight='bold' foreground='#7aa2f7'>%s</span>\\n%b";
      alignment = "center";
      vertical_alignment = "center";
      show_age_threshold = 60;
      ignore_newline = false;
      stack_duplicates = false;
      hide_duplicate_count = true;

      # ───────────────────────────────────────────────
      # Icons
      # ───────────────────────────────────────────────
      enable_recursive_icon_lookup = true;
      icon_theme = "Papirus-Dark, Adwaita";
      icon_position = "left";
      min_icon_size = 60;
      max_icon_size = 90;
      icon_corner_radius = 6;

      # ───────────────────────────────────────────────
      # Behavior
      # ───────────────────────────────────────────────
      sort = false;
      idle_threshold = 0;
      show_indicators = true;
      sticky_history = true;
      history_length = 25;
      browser = "/usr/bin/xdg-open";
      always_run_script = true;
      ignore_dbusclose = false;
      force_xinerama = false;

      # ───────────────────────────────────────────────
      # Progress bar (for volume/brightness)
      # ───────────────────────────────────────────────
      progress_bar = true;
      progress_bar_height = 10;
      progress_bar_frame_width = 0;
      progress_bar_min_width = 125;
      progress_bar_max_width = 250;
      progress_bar_corner_radius = 5;

      # ───────────────────────────────────────────────
      # Mouse actions
      # ───────────────────────────────────────────────
      mouse_left_click = "close_current";
      mouse_middle_click = "do_action, close_current";
      mouse_right_click = "close_all";

      title = "Dunst";
      class = "Dunst";
    };

    # ───────────────────────────────────────────────
    # Urgency levels (Tokyo Night)
    # ───────────────────────────────────────────────
    urgency_low = {
      timeout = 3;
      background = "#1a1b26";
      foreground = "#9ece6a";
    };

    urgency_normal = {
      timeout = 5;
      background = "#1a1b26";
      foreground = "#a9b1d6";
    };

    urgency_critical = {
      timeout = 0;
      background = "#1a1b26";
      foreground = "#f7768e";
    };
  };
}

{ pkgs
, ...
}: {
  enable = true;

  # Shell integration
  shellIntegration.enableZshIntegration = true;

  # Font configuration
  font = {
    name = "JetBrainsMono Nerd Font Mono";
    size = if pkgs.stdenv.isDarwin then 15 else 13;
  };

  settings = {
    # Enable ligatures
    enable_ligatures = "yes";

    # Scrolling
    scrollback_lines = 10000;
    scrolling_speed = "1.0";

    # Cursor
    cursor_shape = "beam";
    cursor_blink_interval = "0.6";
    cursor_blink = "yes";

    # Window padding
    window_padding_width = 8;

    # Mouse support
    mouse_hide_wait = 3000;
    mouse_hide_when_typing = "yes";

    # Window title
    window_title_format = "kitty - {title}";
    hide_window_decorations = "yes";

    # URL settings
    url_launcher = "open";
    detect_urls = "yes";
    url_color = "#c0caf5";
    url_style = "straight";
    url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh";

    # Graphics
    enable_kitty_graphics = "yes";

    # Shell integration
    shell_integration = "yes";

    # Close confirmation
    confirm_os_window_close = 0;

    # Symbol mapping for Nerd Fonts
    symbol_map = "U+E000-U+F8FF,U+F0000-U+FFFFF JetBrainsMono Nerd Font";

    # macOS specific
    macos_option_as_alt = "left";

    # Text composition
    text_composition_strategy = "legacy";

    # Shell command
    # shell =
    #   "/etc/profiles/per-user/shahid/bin/zsh -c \"tmux attach -t zen || tmux new -s zen\"";

    # Tokyo Night theme colors
    background = "#1a1b26";
    foreground = "#c0caf5";
    selection_background = "#283457";
    selection_foreground = "#c0caf5";
    cursor = "#c0caf5";
    cursor_text_color = "#1a1b26";

    # Tabs
    active_tab_background = "#7aa2f7";
    active_tab_foreground = "#16161e";
    inactive_tab_background = "#292e42";
    inactive_tab_foreground = "#545c7e";

    #     background_image = "~/Pictures/Wallpapers/2.png";
    # background_tint = "0.9900";
    # background_image_layout = "cscaled";

    # Windows
    active_border_color = "#7aa2f7";
    inactive_border_color = "#292e42";

    # Normal colors
    color0 = "#15161e";
    color1 = "#f7768e";
    color2 = "#9ece6a";
    color3 = "#e0af68";
    color4 = "#7aa2f7";
    color5 = "#bb9af7";
    color6 = "#7dcfff";
    color7 = "#a9b1d6";

    # Bright colors
    color8 = "#414868";
    color9 = "#f7768e";
    color10 = "#9ece6a";
    color11 = "#e0af68";
    color12 = "#7aa2f7";
    color13 = "#bb9af7";
    color14 = "#7dcfff";
    color15 = "#c0caf5";

    # Extended colors
    color16 = "#ff9e64";
    color17 = "#db4b4b";
  };

  # Keybindings
  keybindings = {
    "ctrl+shift+c" = "copy_to_clipboard";
    "ctrl+shift+v" = "paste_from_clipboard";
  };

  extraConfig = ''
    map shift+enter send_text all \n
  '';
}

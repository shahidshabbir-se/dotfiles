{
  pkgs,
  ...
}: {
    enable = true;

    # Optional: integrate with shells
    enableZshIntegration = true;

    # Your Ghostty settings
    settings = {
      # Theme
            theme = "TokyoNight";
      title = " ";

      # Font configuration
      font-family = "JetBrainsMono Nerd Font";
      font-size = if pkgs.stdenv.isDarwin then 15 else 13;
      font-style = "regular";
      font-style-bold = "bold";
      font-style-italic = "italic";
      font-style-bold-italic = "bold italic";

      # Terminal behavior
      shell-integration = "zsh";
      shell-integration-features = "cursor,sudo,title";

      command =
        if pkgs.stdenv.isDarwin
        then "/etc/profiles/per-user/shahid/bin/zsh -c \"tmux attach -t mini || tmux new -s mini\""
        else "${pkgs.tmux}/bin/tmux";

      # Window settings
      window-decoration = false;
      window-title-font-family = "JetBrainsMono Nerd Font";
      window-padding-x = 8;
      window-padding-y = 8;
      window-padding-balance = true;

      # Cursor
      cursor-style = "block";
      # Uncomment if you want to specify custom cursor colors
      # cursor-color = "#82AAFF";
      # cursor-text = "#FFFFFF";

      # Other settings
      confirm-close-surface = false;
      quit-after-last-window-closed = true;
      mouse-hide-while-typing = true;

      # Performance
      unfocused-split-opacity = 0.8;

      # macOS-specific option (can be ignored if not using macOS)
      macos-option-as-alt = true;

      # Custom keybindings
      keybind = "shift+enter=text:\\x1b\\r";
    };
}

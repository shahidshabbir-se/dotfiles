{
  pkgs,
  ...
}: let
  isMac = pkgs.stdenv.isDarwin;
  fontSize = if isMac then 17.0 else 13.0;
  windowDecorations = if isMac then "RESIZE" else "NONE";
in {
  enable = true;
  package = pkgs.wezterm;

  extraConfig = ''
    return {
      adjust_window_size_when_changing_font_size = false,
      color_scheme = "tokyonight_night",
      enable_tab_bar = false,
      font_size = ${toString fontSize},
      font = wezterm.font("JetBrainsMono Nerd Font"),
<<<<<<< Updated upstream
      window_decorations = "RESIZE",
      window_close_confirmation = "NeverPrompt",
=======
      window_decorations = "${windowDecorations}",
      default_prog = { "${pkgs.zsh}/bin/zsh", "-c", "tmux attach -t main || tmux new -s main" },
>>>>>>> Stashed changes

      window_padding = {
        left = 16,
        right = 8,
        top = "20",
        bottom = 0,
      },

      keys = {
        {
          key = "q",
          mods = "CTRL",
          action = wezterm.action.ToggleFullScreen,
        },
        {
          key = "'",
          mods = "CTRL",
          action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
        },
        { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
      },

      -- Attach to tmux session on startup
      default_prog = { "${pkgs.zsh}/bin/zsh", "-c", "tmux attach -t main || tmux new -s main" },

      mouse_bindings = {
        -- Ctrl-click will open the link under the mouse cursor
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "CTRL",
          action = wezterm.action.OpenLinkAtMouseCursor,
        },
      },
    }
  '';
}

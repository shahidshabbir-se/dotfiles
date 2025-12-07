# ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
# ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
# ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
# ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
# ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
# ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ pkgs
, device
, ...
}:
let
  isMac = pkgs.stdenv.isDarwin;
  # Use device-specific font size, or fall back to scale-based calculation
  fontSize = if device ? fontSize 
             then device.fontSize 
             else if device.display.scale >= 2.0 then 17.0 else 13.0;
  windowDecorations = if isMac then "RESIZE" else "NONE";
in
{
  enable = true;
  package = pkgs.wezterm;

  extraConfig = ''
    return {
      adjust_window_size_when_changing_font_size = false,
      color_scheme = 'tokyonight_night',
      enable_tab_bar = false,
      window_close_confirmation = "NeverPrompt",

      font_size = ${toString fontSize},
      font = wezterm.font("BlexMono Nerd Font"),
      window_decorations = "${windowDecorations}",

      window_padding = {
        left = 12,
        right = 8,
        top = "0.7cell",
        bottom = 0,
      },

      -- Attach to tmux session on startup
      default_prog = {
        "${pkgs.zsh}/bin/zsh",
        "-c",
        "tmux attach -t main || tmux new -s main"
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
        {
          key = "Enter",
          mods = "SHIFT",
          action = wezterm.action({ SendString = "\x1b\r" }),
        },
      },

      mouse_bindings = {
        -- Ctrl-click to open link under cursor
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "CTRL",
          action = wezterm.action.OpenLinkAtMouseCursor,
        },
      },
    }
  '';
}

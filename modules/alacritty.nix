{
  pkgs,
  ...
}: {
  enable = true;
  package = pkgs.alacritty;

  settings = {
    window = {
      padding = {
        x = 4;
        y = 8;
      };
      decorations = "none";
      opacity = 1;
      startup_mode = "Windowed";
      title = "Alacritty";
      dynamic_title = true;
      decorations_theme_variant = "None";
      option_as_alt = "Both";
    };

    general = {
      import = [
        "${pkgs.alacritty-theme}/share/alacritty-theme/tokyo_night.toml"
      ];
      live_config_reload = true;
    };

    font = let
      jetbrainsMono = style: {
        family = "JetBrainsMono Nerd Font";
        inherit style;
      };
    in {
      size = 15;
      offset.y = 2;
      normal = jetbrainsMono "Light";
      bold = jetbrainsMono "Regular";
      italic = jetbrainsMono "Light Italic";
      bold_italic = jetbrainsMono "Regular Italic";
    };

    mouse.hide_when_typing = true;

    cursor = {
      style = "Block";
    };

    env = {
      TERM = "xterm-256color";
    };

    terminal.shell = { 
      program = "zsh"; 
      args = ["-l" "-c" "tmux attach -t mini || tmux new -s mini"]; 
    };
  };
}

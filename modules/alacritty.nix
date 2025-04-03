{ pkgs, ... }:

{
  enable = true;
  package = pkgs.alacritty;

  settings = {
    window = {
      padding = {
        x = 4;
        y = 4;
      };
      decorations = "full";
      opacity = 1;
      startup_mode = "Windowed";
      title = "Alacritty";
      dynamic_title = true;
      decorations_theme_variant = "None";
    };

    general = {
      live_config_reload = true;
    };

    colors = {
      primary = {
        background = "0x1E1D2F";
        foreground = "0xD9E0EE";
      };

      normal = {
        black = "0x6E6C7E";
        blue = "0x96CDFB";
        cyan = "0x89DCEB";
        green = "0xABE9B3";
        magenta = "0xF5C2E7";
        red = "0xF28FAD";
        white = "0xD9E0EE";
        yellow = "0xFAE3B0";
      };

      bright = {
        black = "0x988BA2";
        blue = "0x96CDFB";
        cyan = "0x89DCEB";
        green = "0xABE9B3";
        magenta = "0xF5C2E7";
        red = "0xF28FAD";
        white = "0xD9E0EE";
        yellow = "0xFAE3B0";
      };

      cursor = {
        cursor = "0xF5E0DC";
        text = "0x1E1D2F";
      };
    };

    font = {
      size = 10;
      normal = {
        family = "JetBrainsMono Nerd Font";
        style = "Regular";
      };
      bold = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold";
      };
      italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Italic";
      };
      bold_italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold Italic";
      };
      offset = {
        x = 0;
        y = 0;
      };
    };

    mouse = {
      hide_when_typing = true;
    };

    cursor = {
      style = "Block";
    };

    env = {
      TERM = "xterm-256color";
    };

    terminal.shell = {
      program = "/etc/profiles/per-user/shahid/bin/tmux";
    };
  };
}

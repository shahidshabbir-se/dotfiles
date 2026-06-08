#  ███████╗████████╗ █████╗ ██████╗ ███████╗██╗  ██╗██╗██████╗
#  https://github.com/shahidshabbir-se/dotfiles

{ ... }:

{
  enable = true;
  enableZshIntegration = true;

  settings = {
    add_newline = false;
    command_timeout = 1000;
    palette = "catppuccin_mocha";
    format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

    character = {
      success_symbol = "[❯](bold mauve)";
      error_symbol = "[❯](bold red)";
    };

    directory = {
      format = "[$path]($style) ";
      style = "bold blue";
      truncate_to_repo = true;
      truncation_length = 3;
      truncation_symbol = "…/";
    };

    git_branch = {
      format = "[$branch]($style) ";
      style = "bold lavender";
    };

    git_status = {
      format = "[$all_status$ahead_behind]($style)";
      style = "bold yellow";
    };

    cmd_duration = {
      min_time = 5000;
      format = " took [$duration]($style)";
      style = "bold peach";
    };

    nodejs.disabled = true;
    golang.disabled = true;
    docker_context.disabled = true;

    palettes.catppuccin_mocha = {
      rosewater = "#f5e0dc";
      flamingo = "#f2cdcd";
      pink = "#f5c2e7";
      mauve = "#cba6f7";
      red = "#f38ba8";
      maroon = "#eba0ac";
      peach = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      teal = "#94e2d5";
      sky = "#89dceb";
      sapphire = "#74c7ec";
      blue = "#89b4fa";
      lavender = "#b4befe";
      text = "#cdd6f4";
      subtext1 = "#bac2de";
      subtext0 = "#a6adc8";
      overlay2 = "#9399b2";
      overlay1 = "#7f849c";
      overlay0 = "#6c7086";
      surface2 = "#585b70";
      surface1 = "#45475a";
      surface0 = "#313244";
      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
    };
  };
}

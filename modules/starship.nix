{ pkgs, ... }:

{
  enable = true;
  enableNushellIntegration = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  settings = {
    add_newline = true;
    command_timeout = 1000;
    format = ''$directory $character'';
    palette = "catppuccin_mocha";
    right_format = "$git_branch$git_status$nodejs$golang$docker_context";

    character = {
      disabled = false;
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold fg:red)";
      vimcmd_symbol = "[N] >>>";
    };

    directory = {
      disabled = false;
      format = " [$path]($style)[$read_only]($read_only_style)";
      read_only = " ";
      read_only_style = "red";
      repo_root_format = "[$before_root_path]($style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style)";
      truncate_to_repo = true;
      truncation_length = 3;
      truncation_symbol = "…/";
      use_logical_path = true;
      substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = "󰝚 ";
        "Pictures" = " ";
        "Developer" = "󰲋 ";
      };
    };

    git_branch = {
      format = "[$symbol$branch(:$remote_branch)]($style) ";
      symbol = " ";
    };

    git_status = {
      format = "[[$conflicted](yellow)[$untracked](218)[$modified$renamed](255)[$staged](green)[$deleted](red)($ahead_behind$stashed)]($style)";
      conflicted = " $count ";
      untracked = " $count ";
      modified = " $count ";
      deleted = " $count ";
      staged = " $count ";
      renamed = " $count ";
      stashed = " $count ";
      style = "cyan";
    };

    nodejs = {
      format = "[ $version](bold green)";
    };

    golang = {
      format = "[ $version](bold cyan)";
    };

    docker_context = {
      disabled = false;
    };

    palettes = {
      catppuccin_mocha = {
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
  };
}


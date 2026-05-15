#   █████╗ ████████╗██╗   ██╗██╗███╗   ██╗
#  ██╔══██╗╚══██╔══╝██║   ██║██║████╗  ██║
#  ███████║   ██║   ██║   ██║██║██╔██╗ ██║
#  ██╔══██║   ██║   ██║   ██║██║██║╚██╗██║
#  ██║  ██║   ██║   ╚██████╔╝██║██║ ╚████║
#  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝╚═╝  ╚═══╝
#  https://github.com/shahidshabbir-se/dotfiles

{
  atuin ? null,
  pkgs ? null,
}:
{
  enable = true;
  package = if atuin != null then atuin.packages.x86_64-linux.default else pkgs.atuin;

  # ───────────────────────────────────────────────
  # ▶ Zsh Integration
  # ───────────────────────────────────────────────
  enableZshIntegration = true;

  # ───────────────────────────────────────────────
  # ▶ Atuin Settings
  # ───────────────────────────────────────────────
  settings = {
    auto_sync = true;
    sync_frequency = "5m";
    style = "full"; # Display style: minimal | compact | full
    enter_accept = true;
    keymap_mode = "vim-normal";
  };
}

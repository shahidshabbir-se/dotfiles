#   █████╗ ████████╗██╗   ██╗██╗███╗   ██╗
#  ██╔══██╗╚══██╔══╝██║   ██║██║████╗  ██║
#  ███████║   ██║   ██║   ██║██║██╔██╗ ██║
#  ██╔══██║   ██║   ██║   ██║██║██║╚██╗██║
#  ██║  ██║   ██║   ╚██████╔╝██║██║ ╚████║
#  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝╚═╝  ╚═══╝
#  https://github.com/shahidshabbir-se/dotfiles

{ atuin }:
{
  enable = true;
  package = atuin.packages.x86_64-linux.default;

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

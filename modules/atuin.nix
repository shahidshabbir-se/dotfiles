#   █████╗ ████████╗██╗   ██╗██╗███╗   ██╗
#  ██╔══██╗╚══██╔══╝██║   ██║██║████╗  ██║
#  ███████║   ██║   ██║   ██║██║██╔██╗ ██║
#  ██╔══██║   ██║   ██║   ██║██║██║╚██╗██║
#  ██║  ██║   ██║   ╚██████╔╝██║██║ ╚████║
#  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝╚═╝  ╚═══╝
#  https://github.com/shahidshabbir-se/dotfiles

{
  enable = true;

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

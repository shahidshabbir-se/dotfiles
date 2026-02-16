#  ███████╗███████╗███████╗
#  ██╔════╝╚══███╔╝██╔════╝
#  █████╗    ███╔╝ █████╗  
#  ██╔══╝   ███╔╝  ██╔══╝  
#  ██║     ███████╗██║     
#  ╚═╝     ╚══════╝╚═╝     
#  https://github.com/shahidshabbir-se/dotfiles

{ pkgs }: {
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ Enable FZF prompt in Zsh
  # ───────────────────────────────────────────────
  enableZshIntegration = true;

  # ───────────────────────────────────────────────
  # ▶ Enable FZF prompt in Tmux panes
  # ───────────────────────────────────────────────
  tmux.enableShellIntegration = true;

  # ───────────────────────────────────────────────
  # ▶ Default command (use fd for speed)
  # ───────────────────────────────────────────────
  defaultCommand = "fd --type f --hidden --exclude .git";
  changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  fileWidgetCommand = "fd --type f --hidden --exclude .git";
}

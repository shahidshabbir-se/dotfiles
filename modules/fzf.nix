#  ███████╗███████╗███████╗
#  ██╔════╝╚══███╔╝██╔════╝
#  █████╗    ███╔╝ █████╗  
#  ██╔══╝   ███╔╝  ██╔══╝  
#  ██║     ███████╗██║     
#  ╚═╝     ╚══════╝╚═╝     
#  https://github.com/shahidshabbir-se/dotfiles

{ pkgs, ... }: {
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ Enable FZF prompt in Zsh
  # ───────────────────────────────────────────────
  enableZshIntegration = true;

  # ───────────────────────────────────────────────
  # ▶ Enable FZF prompt in Tmux panes
  # ───────────────────────────────────────────────
  tmux.enableShellIntegration = true;
}

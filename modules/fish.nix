#  ███████╗██╗███████╗██╗  ██╗
#  ██╔════╝██║██╔════╝██║  ██║
#  █████╗  ██║███████╗███████║
#  ██╔══╝  ██║╚════██║██╔══██║
#  ██║     ██║███████║██║  ██║
#  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ ... }: {

  # ───────────────────────────────────────────────
  # ▶ Enable Fish Shell Configuration
  # ───────────────────────────────────────────────
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ Initial Commands on Interactive Launch
  # ───────────────────────────────────────────────
  interactiveShellInit = ''
    set fish_greeting # Disable greeting
  '';

  # ───────────────────────────────────────────────
  # ▶ Final Initialization Commands
  # ───────────────────────────────────────────────
  shellInitLast = ''
    enable_transience
  '';
}

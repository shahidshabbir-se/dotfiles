#  ███████╗██╗███████╗██╗  ██╗
#  ██╔════╝██║██╔════╝██║  ██║
#  █████╗  ██║███████╗███████║
#  ██╔══╝  ██║╚════██║██╔══██║
#  ██║     ██║███████║██║  ██║
#  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ _ }: {
  enable = true;
  interactiveShellInit = ''
    set fish_greeting # Disable greeting
  '';
  shellInitLast = ''
    enable_transience
  '';
}

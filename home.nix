{ config, pkgs, lib, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "shahid";
  home.homeDirectory = "/home/shahid";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them
    fastfetch
  kitty
  tmux
  neovim
  rustup
  git
  swww
  ntfs3g
  cliphist
  wl-clipboard
  bat
  keyd
  yazi
  spotify
  btrfs-progs
  zip
  xz
  spicetify-cli
  eww
  unzip
  ripgrep
 jq
  eza
  fzf
  docker
  zoxide
  nodejs_22
  corepack_22
  mtr
  iperf3
  nmap
  ipcalc
  gnused
  gnutar
  playerctl
  gawk
  zstd
  gnupg
  tree
  noto-fonts-emoji 
  alacritty
  kanshi
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "shahidshabbir-se";
    userEmail = "shahidshabbirse@gmail.com";
  };

home.file.".zshrc".source = ./.config/.zshrc;
home.file.".config/p10k.zsh".source = ./.config/.p10k.zsh;
home.file.".config/kitty".source = ./.config/kitty;
home.file.".config/alacritty".source = ./.config/alacritty;
home.file.".config/yazi".source = ./.config/yazi;
home.file.".config/nvim".source = ./.config/nvim;
home.file.".config/tmux".source = ./.config/tmux;
home.file.".local/share/fonts/JetBrainsMono".source = ./.local/share/fonts/JetBrainsMono;
# home.file.".config/hypr".source = ./config/hypr;
home.file.".config/fastfetch".source = ./.config/fastfetch;



  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}

{ pkgs }:

with pkgs; [
  # Development
  gh
  go
  lazygit
  lazysql
  just
  mise
  fnm
  nixpkgs-fmt
  rustup
  act

  # CLI Utilities
  bat
  btop
  calc
  coreutils
  csview
  fd
  fzf
  gnupg
  htop
  imagemagick
  jq
  jless
  lsd
  lsof
  moreutils
  ncdu
  onefetch
  fastfetch
  ripgrep
  sd
  tldr
  tokei
  wget
  xh
  yazi
  zoxide
  zsh

  # Security
  gitleaks
  openssl

  # Media
  mpd
  mpv
  yt-dlp

  # Networking
  croc
  dogdns
  doppler
  stripe-cli
  socat

  # System / Terminal
  atuin
  sesh
  tmux

  # Fun
  cbonsai
  typtea

  # Fonts / UI
  font-awesome_6

  # Benchmarking
  hyperfine
  wrk
]

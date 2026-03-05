{ pkgs }:

with pkgs; [
  # Development
  gh
  go
  lazygit
  lazysql
  just
  stress
  statix
  killall
  file

  # mise
  # fnm
  nixpkgs-fmt
  rustup
  act
  mysql84
  pgloader

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
  age
  gitleaks
  openssl

  # Media
  mpd
  mpv
  yt-dlp

  # Night Light
  redshift
  gammastep

  # Networking
  croc
  dogdns
  doppler
  stripe-cli
  socat

  # System / Terminal
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

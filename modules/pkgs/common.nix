{ pkgs }:

with pkgs;
[
  # Devops
  kubernetes-helm
  yamllint
  actionlint

  # Development
  gh
  render-cli
  gh-dash
  jujutsu
  watchman
  postgresql
  redis
  restish
  bubblewrap
  uv
  k6
  nixfmt
  go
  lazygit
  lazysql
  just
  stress
  statix
  killall
  file
  eww

  # mise
  # fnm
  nixpkgs-fmt
  rustup
  act
  mysql84
  pgloader

  # CLI Utilities
  bat
  libsixel
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
  eza
  lsof
  moreutils
  ncdu
  pandoc
  (texlive.combine {
    inherit (texlive) scheme-medium collection-latexextra;
  })
  onefetch
  fastfetch
  ripgrep
  sd
  tldr
  tokei
  wget
  yazi
  zoxide
  zsh

  # Security
  age
  gitleaks
  openssl

  # # Media
  # mpd
  # mpv
  # yt-dlp

  # Night Light
  redshift
  gammastep

  # Networking
  doggo
  rar
  tree
  doppler
  stripe-cli
  socat

  # System / Terminal
  playerctl
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

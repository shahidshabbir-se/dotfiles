{ pkgs }:

with pkgs; [
  gitleaks
  csview
  lsof
  openssl
  gh
  # (import ../../modules/droid.nix { inherit pkgs; })
  lazygit
  go
  nixpkgs-fmt
  stripe-cli
  lazysql
  mise
  asdf-vm
  wget
  cbonsai
  mpd
  font-awesome_6
  socat
  imagemagick
  youtube-tui
  mpv
  yt-dlp
  ncdu
  act
  sesh
  lsof
  atuin
  # yt-dlp
  mpv
  # youtube-tui
  lazysql
  btop
  coreutils
  croc
  dogdns
  doppler
  fastfetch
  fd
  fzf
  gnupg
  htop
  jq
  jless
  lsd
  moreutils
  onefetch
  ripgrep
  rustup
  tmux
  typtea
  wrk
  yazi
  zoxide
  zsh
]

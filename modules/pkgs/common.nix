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
  deadnix
  go
  psmisc
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
  (texliveMedium.withPackages (ps: with ps; [ collection-latexextra ]))
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

  gcc
  git-filter-repo
  gnumake

  # # Media
  # mpd
  # mpv
  yt-dlp

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

  # Fun
  cbonsai
  typtea

  # Fonts / UI
  font-awesome_6

  # Documents / PDF
  # poppler-utils provides pdftoppm, pdftotext, pdfinfo, pdffonts, pdfimages
  poppler-utils
  qpdf
  pdftk
  tesseract
  (python3.withPackages (
    ps: with ps; [
      pypdf
      pdfplumber
      reportlab
      pdf2image
      pypdfium2
      pymupdf
      pytesseract
      python-docx
      openpyxl
      python-pptx
      pandas
      numpy
      pillow
      defusedxml
    ]
  ))

  # Benchmarking
  hyperfine
  wrk
]

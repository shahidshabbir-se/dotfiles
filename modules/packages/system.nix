{ pkgs, inputs }: {
  systemPackages = with pkgs; [
    # ────────────────────── Terminal Utilities ──────────────────────
    tmux
    git
    xh
    bat
    keyd
    wget
    fastfetch
    bc
    # neovim
    yazi

    # ────────────────────── File Management ──────────────────────
    zip
    rar
    xz
    parted
    unzip
    tree
    eza
    fd

    # ────────────────────── Data Processing ──────────────────────
    jq
    gawk
    gnupg
    zstd
    ripgrep

    # ────────────────────── Web Browser ──────────────────────
    # inputs.zen-browser.packages."x86_64-linux".default
    google-chrome
    # firefox
  ];
}

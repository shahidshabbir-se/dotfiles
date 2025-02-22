{ pkgs, inputs }: {
  systemPackages = with pkgs; [
    # ────────────────────── Terminal Utilities ──────────────────────
    tmux
    git
    xh
    bat
    keyd
    wget
    nitch
    neovim
    yazi

    # ────────────────────── File Management ──────────────────────
    zip
    rar
    xz
    parted
    unzip
    tree
    eza

    # ────────────────────── Data Processing ──────────────────────
    jq
    gawk
    gnupg
    zstd
    ripgrep

    # ────────────────────── Web Browser ──────────────────────
    brave
  ];
}

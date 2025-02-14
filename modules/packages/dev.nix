{ pkgs }: {
  devPackages = with pkgs; [
    # ────────────────────── Web Development ──────────────────────
    nodejs_22
    nodePackages.prisma
    prisma-engines

    # ────────────────────── Backend Development ──────────────────────
    go
    sqlc
    air
    go-migrate

    # ────────────────────── Android Development ──────────────────────
    watchman
    jdk23
    android-studio

    # ────────────────────── DevOps & Containerization ──────────────────────
    docker
    docker-compose

    # ────────────────────── General Development Tools ──────────────────────
    stylua
    lazygit
    lazydocker
    fzf
    zoxide
    nixpkgs-fmt
    gitleaks
    git-graph
    delta
    nushell
    oh-my-posh
    atac
    atuin
    gnumake
    python314
    rustup
    gcc

    # ────────────────────── Database ──────────────────────
    # postgresql
  ];
}

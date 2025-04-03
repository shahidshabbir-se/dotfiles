{ pkgs }: {
  devPackages = with pkgs; [
    # ────────────────────── Web Development ──────────────────────
    nodejs_22
    prisma
    prisma-engines

    # ────────────────────── Backend Development ──────────────────────
    # go
    # sqlc
    # air
    # go-migrate
    poetry

    # ────────────────────── Android Development ──────────────────────
    watchman
    jdk23
    android-studio

    # ────────────────────── DevOps & Containerization ──────────────────────
    docker
    docker-compose

    # ────────────────────── General Development Tools ──────────────────────
    dnsutils
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
    atac
    atuin
    gnumake
    python314
    rustup
    gcc
    openssl
    sqlfluff

    # ────────────────────── Database ──────────────────────
    # postgresql
    # mongodb-compass
  ];
}

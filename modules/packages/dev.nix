{ pkgs }: {
  devPackages = with pkgs; [
    # ────────────────────── Web Development ──────────────────────
    nodejs_22
    nodePackages.prisma
    prisma-engines

    # ────────────────────── Backend Development ──────────────────────
    go
    sqlc

    # ────────────────────── Android Development ──────────────────────
    jdk23
    android-studio

    # ────────────────────── DevOps & Containerization ──────────────────────
    docker
    docker-compose

    # ────────────────────── General Development Tools ──────────────────────
    stylua
    lazygit
    fzf
    zoxide
    nixpkgs-fmt
    gitleaks
    git-graph
    delta
    nushell
    atac
    atuin
  ];
}

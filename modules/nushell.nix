{ pkgs, ... }: {
  enable = true;
  shellAliases = {
    l = "eza -l --icons --git -a";
    ls = "ls -a";
    lt = "eza --tree --level=2 --long --icons --git";
    ltree = "eza --tree --level=2 --icons --git";
    c = "clear";
    grep = "grep --color=auto";
    rm = "rm -rf";
    fzf = "fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%";
    e = "exit";
    bc = "better-commits";
    cat = "bat --style=plain";
    v = "nvim";
    ov = "nvim (fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --preview-window=right:50%)";

    gs = "git status";
    glog = "git log --oneline --graph --decorate";
    gp = "git push origin HEAD";
    gpu = "git pull origin";
    gdiff = "git diff";
    gco = "git checkout";
    gb = "git branch";
    gba = "git branch -a";
    gadd = "git add";
    ga = "git add -p";
    gcoall = "git checkout -- .";
    gr = "git remote";
    gre = "git reset";
    ggr = "git-graph --model git-flow";
    lzg = "lazygit";

    pi = "pnpm install";
    pd = "pnpm install --save-dev";
    pr = "pnpm run dev";
    ps = "pnpm start";
    pt = "pnpm test";

    d = "docker";
    dc = "docker compose";
    dco = "docker compose";
    dcu = "docker compose up";
    dcd = "docker compose down";
    dps = "docker ps";
    dpa = "docker ps -a";
    dl = "docker ps -l -q";
    di = "docker images";
    dr = "docker run";
    dp = "docker pull";
    dx = "docker exec -it";
    lzd = "lazydocker";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "~" = "cd ~";
  };

  extraConfig = ''
    $env.config.show_banner = false

    source ~/.config/nushell/git-completions.nu
    source ~/.config/nushell/winget-completions.nu
    source ~/.config/nushell/docker-completions.nu
    source ~/.config/nushell/pnpm-completions.nu
    source ~/.config/nushell/docker-completions.nu
    source ~/.config/nushell/rg-completions.nu
    source ~/.config/nushell/adb-completions.nu
    source ~/.config/nushell/nix-completions.nu
    
    # Set Prisma environment variables
    $env.PRISMA_QUERY_ENGINE_LIBRARY = "/nix/store/8qn3lm4mhc6gyly8axawp20k8gynd26y-prisma-engines-6.0.1/lib/libquery_engine.node"
    $env.PRISMA_SCHEMA_ENGINE_BINARY = "/nix/store/8qn3lm4mhc6gyly8axawp20k8gynd26y-prisma-engines-6.0.1/bin/schema-engine"

    # Update PATH properly
    $env.PATH = ($env.PATH | append ($env.HOME | path join "npm-global/bin"))
    $env.PATH = ($env.PATH | append ($env.HOME | path join "go/bin"))

    # Set FZF default options
    $env.FZF_DEFAULT_OPTS = (
      "--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 " +
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc " +
      "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 " +
      "--color=selected-bg:#45475a " +
      "--multi"
    )

    # Set BAT theme
    $env.BAT_THEME = "Catppuccin Mocha"

    # Define Nushell functions

    # Clone a GitHub repo under your sourcername
    def gcs [repo: string] {
      git clone $"git@github.com:shahidshabbir-se/($repo).git"
    }

    def gc [message: string] {
      git commit -m $message
    }

    def gca [message: string] {
      git commit -a -m $message
    }
  '';
}

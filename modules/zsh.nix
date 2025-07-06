#  ███████╗███████╗██╗  ██╗
#  ╚══███╔╝██╔════╝██║  ██║
#    ███╔╝ ███████╗███████║
#   ███╔╝  ╚════██║██╔══██║
#  ███████╗███████║██║  ██║
#  ╚══════╝╚══════╝╚═╝  ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, ... }:

{
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ ZSH History
  # ───────────────────────────────────────────────
  history.size = 0;
  history.ignoreAllDups = false;
  history.path = "/dev/null";

  # ───────────────────────────────────────────────
  # ▶ Shell Aliases
  # ───────────────────────────────────────────────
  shellAliases = {
    # File navigation
    ls = "eza --icons=always --color=always -a";
    ll = " eza --icons=always --color=always -la";
    lt = "eza --tree --level=2 --long --icons --git";
    lt3 = "eza --tree --level=3 --long --icons --git";
    lt4 = "eza --tree --level=4 --long --icons --git";

    # System
    c = "clear";
    grep = "grep --color=auto";
    copy = "pbcopy";
    rm = "rm -rf";

    # FZF / Better Commits
    fzf = "fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%";
    onv = "nvim $(fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%)";
    bc = "better-commits";

    # Exit
    e = "exit";

    # Git Aliases
    gs = "git status";
    gc = "git commit -m";
    gca = "git commit -a -m";
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
    glog = "git log --oneline --graph --decorate";

    gcs = "function _gitclone() { git clone git@github.com:shahidshabbir-se/$1.git; }; _gitclone";
    gch = "function _gch() { if [[ -n \$1 && \$1 =~ ^[0-9]+$ ]]; then git clone --depth \$1 \$2; else git clone \$1; fi; }; _gch";

    killport = "f(){ kill -9 $(lsof -ti tcp:$1); }; f";

    lzg = "lazygit";

    # PNPM
    pi = "pnpm install";
    pd = "pnpm install --save-dev";
    pr = "pnpm run dev";
    ps = "pnpm start";
    pt = "pnpm test";

    # Docker
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

    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../.. ";
    "...." = "cd ../../..";
    "~" = "cd ~";
  };

  # ───────────────────────────────────────────────
  # ▶ Oh-My-Zsh Plugins (optional)
  # ───────────────────────────────────────────────
  oh-my-zsh = {
    enable = false;
    plugins = [
      "git"
      "sudo"
      "command-not-found"
      "pass"
      "poetry"
      "tmux"
      # "kubectl"
      # "kubectx"
      # "rust"
    ];
  };

  # ───────────────────────────────────────────────
  # ▶ Zsh Plugin List
  # ───────────────────────────────────────────────
  plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
    {
      name = "zsh-autosuggestions";
      src = pkgs.zsh-autosuggestions;
      file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
      file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
    }
    {
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
  ];

  # ───────────────────────────────────────────────
  # ▶ Zsh Init Content
  # ───────────────────────────────────────────────
  initContent = ''
    # Bindings
    bindkey '^r' atuin-search
    bindkey '^[[A' atuin-up-search
    bindkey '^[OA' atuin-up-search
    bindkey '^A' beginning-of-line
    bindkey '^E' end-of-line
    bindkey '^U' backward-kill-line
    bindkey '^K' kill-line
    bindkey '^W' backward-kill-word
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^D' delete-char
    bindkey '^?' backward-delete-char
    bindkey '^T' transpose-chars
    bindkey '^[t' transpose-words
    bindkey '^Y' yank
    bindkey '^[o' execute-named-cmd
    bindkey '^F' autosuggest-accept

    # Load Powerlevel10k theme
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # Completion styles for fzf-tab
    zstyle ':completion:*:git-checkout:*' sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    zstyle ':completion:*' menu no

    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:ls:*' fzf-preview 'cat $realpath'
    zstyle ':fzf-tab:*' switch-group '<' '>'

    # Extra PATHs
    export PATH=$PATH:$HOME/go/bin

    # FZF colors
    export FZF_DEFAULT_OPTS=" \
      --color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
      --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
      --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
      --color=selected-bg:#45475a \
      --multi"
  '';
}

{ config, pkgs, lib, ... }:
{
  enable = true;
  history.size = 0;
  history.ignoreAllDups = false;
  history.path = "/dev/null";
  shellAliases = {
    ls = "eza -l --icons --git -a";
    lt = "eza --tree --level=2 --long --icons --git";
    ltree = "eza --tree --level=2  --icons --git";
    c = "clear";
    grep = "grep --color=auto";
    rm = "rm -rf";
    fzf = "fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%";
    e = "exit";
    bc = "better-commits";
    cat = "bat --style=plain";
    nv = "nvim";
    onv = "nvim $(fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%)";

    gs = "git status";
    glog = "git log --oneline --graph --decorate";
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
    gcs = "function _gitclone() { git clone git@github.com:shahidshabbir-se/$1.git; }; _gitclone";
    gch = "function _gch() { if [[ -n \$1 && \$1 =~ ^[0-9]+$ ]]; then git clone --depth \$1 \$2; else git clone \$1; fi; }; _gch";
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

  oh-my-zsh = {
    enable = false;
    plugins = [
      "git"
      "sudo"
      # "kubectl"
      # "kubectx"
      # "rust"
      "command-not-found"
      "pass"
      "poetry"
      "tmux"
    ];
  };
  plugins = [
    {
      name = "zsh-autosuggestions";
      src = pkgs.zsh-autosuggestions;
      file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
    }
    {
      name = "zsh-completions";
      src = pkgs.zsh-completions;
      file = "share/zsh-completions/zsh-completions.zsh";
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

  initExtra = ''
    bindkey '^A' beginning-of-line
    bindkey '^E' end-of-line
    bindkey '^U' backward-kill-line
    bindkey '^K' kill-line
    bindkey '^W' backward-kill-word
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^D' delete-char
    bindkey '^H' backward-delete-char
    bindkey '^T' transpose-chars
    bindkey '^[t' transpose-words
    bindkey '^L' clear-screen
    bindkey '^Y' yank
    bindkey '^[o' execute-named-cmd
    bindkey '^F' autosuggest-accept

    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no
    # preview directory's content with eza when completing cd
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:ls:*' fzf-preview 'cat $realpath'
    # switch group using `<` and `>`
    zstyle ':fzf-tab:*' switch-group '<' '>'
    export PRISMA_QUERY_ENGINE_LIBRARY=/nix/store/8qn3lm4mhc6gyly8axawp20k8gynd26y-prisma-engines-6.0.1/lib/libquery_engine.node
    export PRISMA_SCHEMA_ENGINE_BINARY=/nix/store/8qn3lm4mhc6gyly8axawp20k8gynd26y-prisma-engines-6.0.1/bin/schema-engine
    export PATH=~/npm-global/bin:$PATH
    export PATH=$PATH:$HOME/go/bin
    export FZF_DEFAULT_OPTS=" \
      --color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
      --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
      --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
      --color=selected-bg:#45475a \
      --multi"
    export BAT_THEME="Catppuccin Mocha"
    export PASSWORD_STORE_DIR="$HOME/.password-store"
  '';
}

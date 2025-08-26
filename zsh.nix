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
  history.size = 10000;
  history.ignoreAllDups = true;
  history.path = "${config.xdg.dataHome}/zsh/history";

  # ───────────────────────────────────────────────
  # ▶ Shell Aliases
  # ───────────────────────────────────────────────
  shellAliases = {
    # Directory navigation
    ls = "lsd --icon=always --color=always -a --ignore-glob=node_modules";
    ll = "lsd --icon=always --color=always -la --ignore-glob=node_modules";
    
    # Basic utilities
    rm = "rm -rf";
    c = "clear";
    vi = "nvim";
    ".." = "cd ..";
    e = "exit";
    copy = "pbcopy";
    cat = "bat";
    bc = "better-commits";
    viconf = "cd ~/.config/nvim && nvim .";
    yz = "yazi";
    cc = "claude";

    # Git aliases
    ggr = "git-graph --model git-flow";
    lzg = "lazygit";

    # pnpm aliases
    pa = "pnpm add";
    pad = "pnpm install --save-dev";
    ps = "pnpm start";
    pt = "pnpm test";
    pi = "pnpm install";
    pr = "pnpm run dev";
    pl = "pnpm run lint";
    pf = "pnpm run format";
    pd = "pnpm run debug";
    pb = "pnpm run build";

    # bun aliases
    ba = "bun add";
    bad = "bun add --dev";
    bs = "bun start";
    bt = "bun test";
    bi = "bun install";
    br = "bun run dev";
    bl = "bun run lint";
    bf = "bun run format";
    bd = "bun run debug";
    bb = "bun run build";
  };

  # ───────────────────────────────────────────────
  # ▶ Zinit Plugin Manager Setup
  # ───────────────────────────────────────────────
  plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
      file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
    }
    {
      name = "zsh-completions";
      src = pkgs.zsh-completions;
      file = "share/zsh-completions/zsh-completions.plugin.zsh";
    }
    {
      name = "zsh-autosuggestions";
      src = pkgs.zsh-autosuggestions;
      file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
    }
    {
      name = "zsh-you-should-use";
      src = pkgs.zsh-you-should-use;
      file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
    }
    {
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
  ];

  # ───────────────────────────────────────────────
  # ▶ Oh-My-Zsh Plugin Snippets
  # ───────────────────────────────────────────────
  oh-my-zsh = {
    enable = true;
    plugins = [
      "git"
      "docker"
      "docker-compose"
      "npm"
      "kubectl"
      "tmux"
    ];
  };

  # ───────────────────────────────────────────────
  # ▶ Zsh Init Content
  # ───────────────────────────────────────────────
  initContent = ''
    # Powerlevel10k configuration
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    # Completion styling
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu no
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always --icon=always $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd --color=always --icon=always $realpath'
    zstyle ':fzf-tab:complete:*' fzf-preview '[[ -d $realpath ]] && lsd --color=always --icon=always $realpath || bat --style=numbers --color=always --paging=never $realpath'

    # FZF colors (Tokyo Night theme)
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
      --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
      --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff
      --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
      --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

    # Key bindings
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
    bindkey '^L' clear-screen
    bindkey '^Y' yank
    bindkey '^[o' execute-named-cmd
    bindkey '^F' autosuggest-accept

    # Load completions
    autoload -Uz compinit && compinit

    # Custom lt function for tree view
    lt() {
      local depth=''${1:-2}
      lsd --tree --depth "$depth" --long --icon=always --git --ignore-glob=node_modules
    }

    # Tool initializations
    eval "$(atuin init zsh --disable-up-arrow)"
    eval "$(fzf --zsh)"
    eval "$(zoxide init --cmd cd zsh)"

    # Environment variables
    export PATH="$HOME/.bun/bin:$PATH"
    export EDITOR="nvim"

    # Docker completion (if available)
    if command -v docker &>/dev/null; then
      eval "$(docker completion zsh)"
    fi
  '';
}

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
    ls = "lsd --icon=always --color=always -a --ignore-glob=node_modules --ignore-glob=.DS_Store";
    ll = "lsd --icon=always --color=always -la --ignore-glob=node_modules --ignore-glob=.DS_Store";

    tree = "lsd --tree --depth 1";

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
    cr = "crush";

    # Git aliases
    ggr = "git log --oneline --graph --decorate --all";
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
    export FZF_DEFAULT_OPTS="\
      --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 \
      --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff \
      --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
      --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

    fvim() {
      nvim "$(fzf)"
      }

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

    ghc() {
      local repo="''$1"
      local target_dir="''$2"
  
      if [[ -z "''$repo" ]]; then
        echo "Usage: ghc <repo-name> [target-directory]"
        echo "Examples:"
        echo "  ghc my-repo"
        echo "  ghc my-repo custom-folder"
        echo "  ghc user/repo"
        return 1
      fi
  
      # If repo doesn't contain '/', prepend your username
      if [[ "''$repo" != *"/"* ]]; then
        repo="shahidshabbir-se/''$repo"
      fi
  
      # Use target directory if provided, otherwise use repo name
      local dir="''${target_dir:-$(basename "''$repo")}"
      
      echo " Cloning repository: ''$repo"
      echo " Target directory: ''$dir"
  
      # Try SSH first, fallback to HTTPS if it fails
      echo " Attempting SSH clone..."
      if git clone --progress "git@github.com:''${repo}.git" "''$dir" 2>&1; then
        echo " Successfully cloned via SSH"
      else
        echo " SSH clone failed, trying HTTPS..."
        if git clone --progress "https://github.com/''${repo}.git" "''$dir" 2>&1; then
          echo " Successfully cloned via HTTPS"
        else
          echo " Clone failed. Check repository name and permissions."
          return 1
        fi
      fi
      
      echo " Repository cloned to: ''$dir"
    }

    pw() {
      python3 -c 'import secrets, string; print("".join(secrets.choice(string.ascii_letters + string.digits + "!@#$%^&*()_+-=") for _ in range(32)))' | pbcopy
    }


    # Environment variables
    export TERM="xterm-256color"
    export PATH="$HOME/.bun/bin:$PATH"
    export PATH="$HOME/.cache/.bun/bin:$PATH"
    export PATH="$PATH:$(go env GOPATH)/bin"
    export EDITOR="nvim"
    export BROWSER="Zen"
    export _ZO_DOCTOR=0

    # Docker completion (if available)
    if command -v docker &>/dev/null; then
      eval "$(docker completion zsh)"
    fi

      eval "$(fnm env --use-on-cd)"
  '';
}

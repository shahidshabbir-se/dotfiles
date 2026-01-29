#  ███████╗███████╗██╗  ██╗
#  ╚══███╔╝██╔════╝██║  ██║
#    ███╔╝ ███████╗███████║
#   ███╔╝  ╚════██║██╔══██║
#  ███████╗███████║██║  ██║
#  ╚══════╝╚══════╝╚═╝  ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, ... }:

{
  enable = true;

  # # ───────────────────────────────────────────────
  # # ▶ ZSH History
  # # ───────────────────────────────────────────────
  # history.size = 10000;
  # history.ignoreAllDups = true;
  # history.path = "${config.xdg.dataHome}/zsh/history";

  # ───────────────────────────────────────────────
  # ▶ Shell Aliases
  # ───────────────────────────────────────────────
  shellAliases = {
    ls = "lsd --icon=always --color=always -a --ignore-glob=node_modules --ignore-glob=.DS_Store";
    ll = "lsd --icon=always --color=always -la --ignore-glob=node_modules --ignore-glob=.DS_Store";
    mkdir = "mkdir -p";

    tree = "lsd --tree --depth 1";

    # Basic utilities
    rm = "rm -rI";
    rmf = "rm -rf";
    c = "clear";
    vi = "nvim";
    ".." = "cd ..";
    e = "exit";
    cat = "bat";
    bc = "better-commits";
    viconf = "cd ~/.config/nvim && nvim .";
    yz = "yazi";
    cc = "claude";
    # cc = "eval \"$(ccr activate)\" && NODE_OPTIONS=\"--no-deprecation\" claude";
    oc = "opencode";
    cr = "crush";
    cliproxyapi = "cliproxyapi -config ~/.config/cliproxyapi/config.yaml";

    # Git aliases
    ggr = "git log --oneline --graph --decorate --all";
    lzg = "lazygit";

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
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
      file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
    }
  ];

  # ───────────────────────────────────────────────
  # ▶ Oh-My-Zsh Plugin Snippets
  # ───────────────────────────────────────────────
  # oh-my-zsh = {
  #   enable = true;
  #   plugins = [
  #     "git"
  #     "docker"
  #     "docker-compose"
  #     "npm"
  #     "kubectl"
  #     "tmux"
  #   ];
  # };

  # ───────────────────────────────────────────────
  # ▶ Zsh Init Conten
  # ───────────────────────────────────────────────
  initContent = ''
        # Set ZSH cache directory (for dynamic completions)
        export ZSH_CACHE_DIR="${config.xdg.cacheHome}/zsh"
        mkdir -p "$ZSH_CACHE_DIR/completions"

        # Powerlevel10k configuration
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        if [[ -d $HOME/.zsh/aliases ]]; then
          for file in $HOME/.zsh/aliases/*.zsh; do
            [[ -f "$file" ]] && source "$file"
          done
        fi

        # Add completion directories to fpath
        # Static completions from dotfiles and dynamic completions from cache
        fpath=(${config.home.homeDirectory}/dotfiles/config/zsh/completions $ZSH_CACHE_DIR/completions $fpath)

        # Lazy-load completions (only regenerate once per day)
        autoload -Uz compinit
        if [[ -n $ZSH_CACHE_DIR/zcompdump(#qN.mh+24) ]]; then
          compinit -d "$ZSH_CACHE_DIR/zcompdump"
        else
          compinit -C -d "$ZSH_CACHE_DIR/zcompdump"
        fi

        # Word characters (treat hyphen as word separator so Ctrl+W stops at it)
        WORDCHARS='*?_[]~=&;!#$%^(){}<>'

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
    
        # FZF-TAB configuration
        zstyle ":fzf-tab:*" fzf-flags --border=rounded --color=border:#7dcfff --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a --preview-window=right:50%:wrap:border-rounded --height=60% --min-height=15
    
        # Disable preview by default
        zstyle ":fzf-tab:*" fzf-preview ""
    
        # Enable preview only for specific commands
        zstyle ":fzf-tab:complete:cd:*" fzf-preview "lsd --color=always --icon=always \$realpath"
        zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview "lsd --color=always --icon=always \$realpath"
        zstyle ":fzf-tab:complete:ls:*" fzf-preview "[[ -d \$realpath ]] && lsd --color=always --icon=always \$realpath || bat --style=numbers --color=always --paging=never \$realpath"
        zstyle ":fzf-tab:complete:cat:*" fzf-preview "bat --style=numbers --color=always --paging=never \$realpath"
        zstyle ":fzf-tab:complete:bat:*" fzf-preview "bat --style=numbers --color=always --paging=never \$realpath"
        zstyle ":fzf-tab:complete:nvim:*" fzf-preview "[[ -d \$realpath ]] && lsd --color=always --icon=always \$realpath || bat --style=numbers --color=always --paging=never \$realpath"
        zstyle ":fzf-tab:complete:vi:*" fzf-preview "[[ -d \$realpath ]] && lsd --color=always --icon=always \$realpath || bat --style=numbers --color=always --paging=never \$realpath"

        # FZF colors (Tokyo Night theme)
        export FZF_DEFAULT_OPTS="\
          --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 \
          --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff \
          --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
          --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
          --border=rounded \
          --color=border:#7dcfff \
          --preview 'bat --style=numbers --color=always --line-range :500 {}' \
          --preview-window 'right:50%:wrap:border-rounded'"

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
        bindkey '^[[3~' delete-char  # DEL key
        bindkey '^?' backward-delete-char
        bindkey '^T' transpose-chars
        bindkey '^[t' transpose-words
        bindkey '^L' clear-screen
        bindkey '^Y' yank
        bindkey '^[o' execute-named-cmd
    bindkey '^F' autosuggest-accept

        # Edit command in $EDITOR (Ctrl+X Ctrl+E)
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^X^E' edit-command-line

        # Vi mode edit command
        bindkey -M vicmd 'v' edit-command-line

        # Undo (Ctrl+_)
        bindkey '^_' undo

        # Magic Space - Expand history expressions
        bindkey ' ' magic-space

        # Suffix aliases - open files by extension
        alias -s json=jless
        alias -s md=bat
        alias -s txt=bat
        alias -s log=bat
        alias -s py=$EDITOR
        alias -s js=$EDITOR
        alias -s ts=$EDITOR
        alias -s rs=$EDITOR
        alias -s go=$EDITOR
        alias -s html=${if pkgs.stdenv.isDarwin then "open" else "xdg-open"}  # open in default browser

        # Global aliases for output redirection
        alias -g NE='2>/dev/null'     # Redirect stderr only
        alias -g NO='>/dev/null'      # Redirect stdout only
        alias -g NUL='>/dev/null 2>&1' # Redirect both stdout and stderr
        alias -g J='| jq'            # Pipe to jq
        alias -g V='| nvim -'        # Pipe to nvim
        alias -g C="| ${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"  # Copy to clipboard

        # zmv - Advanced batch rename/move
        autoload -Uz zmv
        alias zcp='zmv -C'  # Copy with patterns
        alias zln='zmv -L'  # Link with patterns

        # Hash directory shortcuts
        hash -d dot=~/dotfiles
        hash -d dl=~/Downloads
        hash -d dev=~/Developer
        hash -d doc=~/Documents
        hash -d devf=~/Developer/freelance/
        hash -d devp=~/Developer/personal/
        hash -d ccd=~/.claude
        hash -d ocd=~/.opencode

        # Custom widgets
        function clear-screen-and-scrollback() {
          echoti civis >"$TTY"
          printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
          echoti cnorm >"$TTY"
          zle redisplay
        }
        zle -N clear-screen-and-scrollback
        bindkey '^X^L' clear-screen-and-scrollback

        function copy-buffer-to-clipboard() {
          echo -n "$BUFFER" | ${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}
          zle -M "Copied to clipboard"
        }
        zle -N copy-buffer-to-clipboard
        bindkey '^X^C' copy-buffer-to-clipboard

        # Hotkey insertions - text snippets
        bindkey -s '^Xgc' 'git commit -m ""\C-b'    # Git commit template
        bindkey -s '^Xgp' 'git push origin '         # Git push origin
        bindkey -s '^Xgs' 'git status\n'             # Git status
        bindkey -s '^Xgl' 'git log --oneline -n 10\n' # Git log

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
          local clip_cmd="${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"}"
          python3 -c 'import secrets, string; print("".join(secrets.choice(string.ascii_letters + string.digits + "!@#$%^&*()_+-=") for _ in range(32)))' | $clip_cmd
        }

        # FZF integrations
        # Kill process with fzf
        fkill() {
          local pid
          pid=$(ps -ef | sed 1d | fzf -m --header='[kill:process]' --preview-window=hidden | awk '{print $2}')
          if [ "x$pid" != "x" ]; then
            echo $pid | xargs kill -''${1:-9}
          fi
        }

        # Docker container selection with fzf
        fdock() {
          local container
          container=$(docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' | fzf --header-lines=1 --header='[docker:container]' --preview-window=hidden) &&
          echo $container | awk '{print $1}'
        }

        # Docker logs with fzf
        fdlog() {
          local container
          container=$(docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' | fzf --header-lines=1 --header='[docker:logs]' --preview-window=hidden | awk '{print $1}') &&
          [ -n "$container" ] && docker logs -f "$container"
        }

        # Environment variable viewer with fzf
        fenv() {
          env | fzf --preview 'echo {}' --preview-window=down:3:wrap --header='[env:variables]'
        }

        # Man page search with fzf
        fman() {
          man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' --header='[man:pages]' | awk '{print $1}' | xargs man
        }

        # Directory history with fzf (using zoxide)
        fz() {
          local dir
          dir=$(zoxide query -l | fzf --preview 'lsd --color=always --icon=always {}' --header='[zoxide:jump]') &&
          cd "$dir"
        }


        # Environment variables
        export TERM="xterm-256color"
        export TMPDIR=$HOME/tmp
        export EDITOR="nvim"
        export BROWSER="Zen"
        export _ZO_DOCTOR=0
        export GOPATH="$HOME/go"
        export PATH="$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.local/bin:$HOME/.bun/bin:$HOME/.cache/.bun/bin:$PATH"
  '';
}

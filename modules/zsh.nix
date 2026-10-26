{
  config,
  pkgs,
  browser,
  ...
}:

let
  omz = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
  # Keep upstream Docker aliases without its runtime completion generation.
  dockerAliases =
    pkgs.runCommand "omz-docker-aliases.zsh" { nativeBuildInputs = [ pkgs.python3 ]; }
      ''
        python3 - <<'PY'
        import os
        from pathlib import Path

        source = Path("${omz}/plugins/docker/docker.plugin.zsh").read_text()
        boundary = '\nif (( ! $+commands[docker] )); then\n'
        assert source.count(boundary) == 1, "OMZ Docker layout changed; review aliases-only boundary"
        aliases, _, _ = source.partition(boundary)
        assert aliases.startswith("alias "), "OMZ Docker alias section changed"
        Path(os.environ["out"]).write_text(aliases + '\n')
        PY
      '';
in
{
  enable = true;

  # Static completions, initialized once before plugins.
  completionInit = ''
    fpath=(
      ${pkgs.zsh-completions}/share/zsh/site-functions
      ${pkgs.bun}/share/zsh/site-functions
      ${omz}/plugins/docker/completions
      ${omz}/plugins/docker-compose
      $fpath
    )
    mkdir -p "${config.xdg.cacheHome}/zsh"
    autoload -Uz compinit
    compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
  '';

  # Highlight after custom widgets are registered.
  syntaxHighlighting.enable = true;

  # Plugins
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
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
    {
      name = "zsh-you-should-use";
      src = pkgs.zsh-you-should-use;
      file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
    }
  ];

  # Personal aliases
  shellAliases = {
    # Files
    ls = "eza --icons=always --color=always -la --git-ignore --ignore-glob=node_modules --ignore-glob=.DS_Store";
    ll = "eza --icons=always --color=always -a --git-ignore --ignore-glob=node_modules --ignore-glob=.DS_Store";
    l = "eza --icons=always --color=always -la --git-ignore --ignore-glob=node_modules --ignore-glob=.DS_Store";
    tree = "eza --tree --level=1 --icons=always";
    mkdir = "mkdir -p";

    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "......" = "cd ../../../../..";

    # Utilities
    c = "clear";
    e = "exit";
    rm = "rm -rI";
    rmf = "rm -rf";
    cat = "bat";
    sed = "sd";
    time = "hyperfine";

    # Editors
    vi = "nvim";
    yz = "yazi";
    viconf = "cd ~/.config/nvim && nvim .";

    # NixOS
    nsp = "sudo nixos-rebuild switch --flake ~/dotfiles#pc";

    # Git
    ggr = "git log --oneline --graph --decorate --all";
    lzg = "lazygit";

    # Bun
    ba = "bun add";
    bad = "bun add --dev";
    bi = "bun install";
    bs = "bun start";
    bt = "bun test";
    br = "bun run dev";
    bb = "bun run build";
    bl = "bun run lint";
    bf = "bun run format";
    bd = "bun run debug";

    # npm
    na = "npm install";
    nad = "npm install --save-dev";
    ni = "npm install";
    ns = "npm start";
    nt = "npm test";
    nr = "npm run dev";
    nb = "npm run build";
    nl = "npm run lint";
    nf = "npm run format";
    nd = "npm run debug";
  };

  shellGlobalAliases = {
    NE = "2>/dev/null";
    NO = ">/dev/null";
    NUL = ">/dev/null 2>&1";
    J = "| jq";
    V = "| nvim -";
    C = "| _clip";
  };

  initContent = ''
    # Use Emacs keybindings
    bindkey -e

    # Ignore stale Hyprland sockets
    unset HYPRLAND_INSTANCE_SIGNATURE

    # Target the first running Hyprland instance
    hyprctl() {
      if command hyprctl -j instances >/dev/null 2>&1; then
        command hyprctl -i 0 "$@"
      else
        command hyprctl "$@"
      fi
    }

    # Upstream shortcuts only; Powerlevel10k owns the prompt
    zstyle ':omz:alpha:lib:git' async-prompt no
    source ${omz}/lib/git.zsh
    source ${omz}/plugins/git/git.plugin.zsh
    source ${dockerAliases}
    source ${omz}/plugins/docker-compose/docker-compose.plugin.zsh

    # Prompt and local secrets
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    [[ -f ~/.secrets ]] && source ~/.secrets

    # Ctrl+W stops at hyphens
    WORDCHARS='*?_[]~=&;!#$%^(){}<>'

    # Completion
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu no

    # fzf: Tokyo Night, transparent background
    export FZF_DEFAULT_OPTS="\
      --color=fg:#c0caf5,bg:-1,hl:#bb9af7 \
      --color=fg+:#c0caf5,bg+:-1,hl+:#7dcfff \
      --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
      --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a,preview-bg:-1 \
      --border=rounded \
      --color=border:#7dcfff \
      --preview 'bat --style=numbers --color=always --line-range :500 {}' \
      --preview-window 'right:50%:wrap:border-rounded'"

    # fzf-tab
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':fzf-tab:*' default-color ""
    zstyle ':fzf-tab:*' fzf-flags --border=rounded --color=border:#7dcfff --color=fg:#c0caf5,bg:-1,hl:#bb9af7 --color=fg+:#c0caf5,bg+:-1,hl+:#7dcfff --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a,preview-bg:-1 --preview-window=right:50%:wrap:border-rounded --height=60% --min-height=15
    zstyle ':fzf-tab:*' switch-group '<' '>'

    # Previews for supported commands
    zstyle ':fzf-tab:*' fzf-preview ""
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons=always $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons=always $realpath'
    zstyle ':fzf-tab:complete:ls:*' fzf-preview '[[ -d $realpath ]] && eza --color=always --icons=always $realpath || bat --style=numbers --color=always --paging=never $realpath'
    zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --style=numbers --color=always --paging=never $realpath'
    zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --style=numbers --color=always --paging=never $realpath'
    zstyle ':fzf-tab:complete:nvim:*' fzf-preview '[[ -d $realpath ]] && eza --color=always --icons=always $realpath || bat --style=numbers --color=always --paging=never $realpath'
    zstyle ':fzf-tab:complete:vi:*' fzf-preview '[[ -d $realpath ]] && eza --color=always --icons=always $realpath || bat --style=numbers --color=always --paging=never $realpath'

    # File-extension aliases
    alias -s json=jless
    alias -s md=leaf
    alias -s txt=bat
    alias -s log=bat
    alias -s py=$EDITOR
    alias -s js=$EDITOR
    alias -s ts=$EDITOR
    alias -s rs=$EDITOR
    alias -s go=$EDITOR
    alias -s nix=$EDITOR
    alias -s html=${if pkgs.stdenv.hostPlatform.isDarwin then "open" else "xdg-open"}

    # Pick a Markdown file and replace fzf with Leaf.
    fmd() {
      setopt localoptions pipefail
      fd --type f --extension md --print0 . "$@" |
        fzf --read0 --no-multi --bind 'enter:become(leaf -- {})'
    }

    # Clipboard: macOS, X11, Wayland
    _clip() {
      ${
        if pkgs.stdenv.hostPlatform.isDarwin then
          "pbcopy"
        else
          ''
            if [ "$XDG_SESSION_TYPE" = "x11" ]; then
              xclip -selection clipboard
            else
              wl-copy
            fi''
      }
    }

    # Batch copy and link
    autoload -Uz zmv
    alias zcp='zmv -C'
    alias zln='zmv -L'

    # Directory shortcuts
    hash -d dot=~/dotfiles
    hash -d dl=~/Downloads
    hash -d dev=~/Developer
    hash -d doc=~/Documents
    hash -d devf=~/Projects/freelance/
    hash -d devp=~/Projects/personal/
    hash -d ccd=~/.claude

    # Helpers
    lt() {
      local depth=''${1:-2}
      eza --tree --level="$depth" --long --icons=always --git-ignore --ignore-glob=node_modules
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

      if [[ "''$repo" != *"/"* ]]; then
        repo="shahidshabbir-se/''$repo"
      fi

      local dir="''${target_dir:-$(basename "''$repo")}"

      echo " Cloning repository: ''$repo"
      echo " Target directory: ''$dir"

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
      python3 -c 'import secrets, string; print("".join(secrets.choice(string.ascii_letters + string.digits + "!@#$%^&*()_+-=") for _ in range(32)))' | _clip
    }

    # Keep fzf in foreground pipelines; capture via $(...) breaks terminal input in Herdr.
    fkill() {
      setopt localoptions pipefail
      local pid
      ps -ef | command sed 1d |
        fzf -m --header='[kill:process]' --preview-window=hidden |
        awk '{print $2}' |
        while IFS= read -r pid; do
          kill -"''${1:-9}" -- "$pid"
        done
    }

    fdock() {
      setopt localoptions pipefail
      docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' |
        fzf --header-lines=1 --header='[docker:container]' --preview-window=hidden |
        awk '{print $1}'
    }

    fdlog() {
      setopt localoptions pipefail
      local container
      docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}' |
        fzf --header-lines=1 --header='[docker:logs]' --preview-window=hidden |
        awk '{print $1}' |
        IFS= read -r container && docker logs -f "$container"
    }

    fenv() {
      env | fzf --preview 'echo {}' --preview-window=down:3:wrap --header='[env:variables]'
    }

    fman() {
      man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' --header='[man:pages]' | awk '{print $1}' | xargs man
    }

    fz() {
      setopt localoptions pipefail
      local dir
      zoxide query -l |
        fzf --preview 'eza --color=always --icons=always {}' --header='[zoxide:jump]' |
        IFS= read -r dir && cd "$dir"
    }

    # Keybindings
    bindkey '^A' beginning-of-line
    bindkey '^E' end-of-line
    bindkey '^U' backward-kill-line
    bindkey '^K' kill-line
    bindkey '^W' backward-kill-word
    bindkey '^[b' backward-word
    bindkey '^[f' forward-word
    bindkey '^D' delete-char
    bindkey '^[[3~' delete-char
    bindkey '^?' backward-delete-char
    bindkey '^T' transpose-chars
    bindkey '^[t' transpose-words
    bindkey '^L' clear-screen
    bindkey '^Y' yank
    bindkey '^[o' execute-named-cmd
    bindkey '^F' autosuggest-accept

    # Ctrl+G edits the command in $EDITOR
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey '^G' edit-command-line
    bindkey '^Ou' undo
    bindkey ' ' magic-space

    # Ctrl+O is a prefix, not a standalone history action.
    bindkey -r '^O'

    # Custom widgets
    function clear-screen-and-scrollback() {
      zle clear-screen
      printf '%b' '\e[3J' >"$TTY"
    }
    zle -N clear-screen-and-scrollback
    bindkey '^Ol' clear-screen-and-scrollback

    function copy-buffer-to-clipboard() {
      if printf '%s' "$BUFFER" | _clip; then
        zle -M "Copied to clipboard"
      else
        zle -M "Clipboard copy failed"
        return 1
      fi
    }
    zle -N copy-buffer-to-clipboard
    bindkey '^Oc' copy-buffer-to-clipboard

    # Git snippets (Ctrl+O prefix)
    bindkey -s '^Ogc' 'git commit -m ""\C-b'
    bindkey -s '^Ogp' 'git push origin '
    bindkey -s '^Ogs' 'git status\n'
    bindkey -s '^Ogl' 'git log --oneline -n 10\n'

    # History search
    if (( $+commands[atuin] )); then
      bindkey '^R' _atuin_search_widget
    fi

    # Environment
    export TERM="xterm-256color"
    export TMPDIR=$HOME/tmp
    export EDITOR="nvim"
    export BROWSER="${browser}"
    export _ZO_DOCTOR=0

    # Herdr tab titles
    for _f in ''${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
      source "$_f"
      break
    done
  '';
}

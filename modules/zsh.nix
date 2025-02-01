{ config, pkgs, lib, ... }:
{
  enable = true;
  history.size = 10000;
  history.ignoreAllDups = true;
  history.path = "$HOME/.zsh_history";
  history.ignorePatterns = [ "rm *" "pkill *" ];
  shellAliases = {
    t = "tree -L";
    t1 = "tree -L 1";
    t2 = "tree -L 2";
    t3 = "tree -L 3";

    c = "clear";
    l = "eza --icons=always --git -a --no-time --no-user --no-permissions";

    grep = "grep --color=auto";
    pwd = "pwd -P";
    gs = "git status";
    gl = "git log --oneline --graph --decorate";
    gco = "git checkout";
    gc = "git commit";
    gca = "git commit -a";
    gcm = "git commit -m";
    gp = "git push";
    gpo = "git push origin";
    gpl = "git pull";
    ga = "git add";
    gb = "git branch";
    gup = "git pull --rebase";
    gcs = "function _gitclone() { git clone git@github.com:shahidshabbir-se/$1.git; }; _gitclone";
    gch = "function _gch() { git clone $1; }; _gch";
    ggr = "git-graph --model git-flow";

    ni = "pnpm install";
    nd = "pnpm install --save-dev";
    nr = "pnpm run dev";
    ns = "pnpm start";
    nt = "pnpm test";

    d = "docker";
    dc = "docker-compose";
    dps = "docker ps";
    di = "docker images";
    dcu = "docker-compose up";
    dcd = "docker-compose down";
    dr = "docker run";
    dp = "docker pull";

    rm = "rm -rf";
    fzf = "fzf --preview \"bat --style=numbers --color=always --line-range :500 {}\" --preview-window=right:50%";
    e = "exit";
    bc = "better-commits";
    cat = "bat --style=plain";
    nv = "nvim";

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
      "kubectl"
      "kubectx"
      "rust"
      "command-not-found"
      "pass"
    ];
  };
  zplug = {
    enable = true;
    plugins = [
      { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
      { name = "zsh-users/zsh-completions"; } # Simple plugin installation
      { name = "zsh-users/zsh-syntax-highlighting"; } # Simple plugin installation
      { name = "zsh-users/zsh-history-substring-search"; } # Simple plugin installation
      { name = "junegunn/fzf"; } # Simple plugin installation
      { name = "Aloxaf/fzf-tab"; } # Simple plugin installation
      {
        name = "romkatv/powerlevel10k";
        tags = [ "as:theme" "depth:1" ];
      } # Installations with additional options. For the list of options, please refer to Zplug README.
    ];
  };

  initExtra = ''
    bindkey '^A' beginning-of-line
    bindkey '^E' end-of-line
    bindkey '^U' backward-kill-line
    bindkey '^K' kill-line
    bindkey '^W' backward-kill-word
    bindkey '^B' backward-word
    bindkey '^F' forward-word
    bindkey '^D' delete-char
    bindkey '^H' backward-delete-char
    bindkey '^T' transpose-chars
    bindkey '^[t' transpose-words
    bindkey '^L' clear-screen
    bindkey '^Y' yank
    bindkey '^[o' execute-named-cmd
    bindkey '^@' autosuggest-accept

    [[ ! -f ${./p10k.zsh} ]] || source ${./p10k.zsh}
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
  '';
}

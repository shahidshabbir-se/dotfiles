ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light MichaelAquilina/zsh-you-should-use
zinit light Aloxaf/fzf-tab

zi snippet OMZP::git
zi snippet OMZP::docker
zi snippet OMZP::docker-compose
zi snippet OMZP::npm
zi snippet OMZP::kubectl
zi snippet OMZP::tmux

autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always --icon=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd --color=always --icon=always $realpath'
zstyle ':fzf-tab:complete:*' fzf-preview '[[ -d $realpath ]] && lsd --color=always --icon=always $realpath || bat --style=numbers --color=always --paging=never $realpath'

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
	--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
	--color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff
	--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
	--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

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

alias ls='lsd --icon=always --color=always -a --ignore-glob=node_modules'
alias ll='lsd --icon=always --color=always -la --ignore-glob=node_modules'
lt() {
  local depth=${1:-2}
  lsd --tree --depth "$depth" --long --icon=always --git --ignore-glob=node_modules
}

alias rm='rm -rf'
alias c='clear'
alias vi="nvim"
alias ..="cd .."
alias e="exit"
alias copy="pbcopy"
alias cat="bat"
alias bc="better-commits"
alias viconf="cd ~/.config/nvim && nvim ."
alias yz="yazi"
alias cc="claude"

alias ggr="git-graph --model git-flow"
alias lzg="lazygit"

# pnpm aliases
alias pa="pnpm add"
alias pad="pnpm install --save-dev"
alias ps="pnpm start"
alias pt="pnpm test"
alias pi="pnpm install"
alias pr="pnpm run dev"
alias pl="pnpm run lint"
alias pf="pnpm run format"
alias pd="pnpm run debug"
alias pb="pnpm run build"

# bun aliases
alias ba="bun add"
alias bad="bun add --dev"
alias bs="bun start"
alias bt="bun test"
alias bi="bun install"
alias br="bun run dev"
alias bl="bun run lint"
alias bf="bun run format"
alias bd="bun run debug"
alias bb="bun run build"

eval "$(atuin init zsh --disable-up-arrow)"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

export PATH="$HOME/.bun/bin:$PATH"
export EDITOR="nvim"

if command -v docker &>/dev/null; then
  eval "$(docker completion zsh)"
fi

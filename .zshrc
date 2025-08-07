
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
FPATH="$HOME/.docker/completions:$FPATH"

plugins=(
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  Aloxaf/fzf-tab
  MichaelAquilina/zsh-you-should-use
  romkatv/powerlevel10k
)
for plugin in "${plugins[@]}"; do
  zinit ice depth"1"
  zinit light "$plugin"
done


[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zi snippet OMZP::git
zi snippet OMZP::docker
zi snippet OMZP::docker-compose
zi snippet OMZP::npm
zi snippet OMZP::kubectl
zi snippet OMZP::tmux

export SUDO_PROMPT="Deploying root access for %u. Password pls: "

eval "$(atuin init zsh --disable-up-arrow)"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

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

alias ls='eza --icons=always --color=always -a --ignore-glob=node_modules'
alias ll='eza --icons=always --color=always -la --ignore-glob=node_modules'
alias lt4='eza --tree --level=4 --long --icons --git --ignore-glob=node_modules'
alias lt2='eza --tree --level=2 --long --icons --git --ignore-glob=node_modules'
alias lt3='eza --tree --level=3 --long --icons --git --ignore-glob=node_modules'
alias ltree='eza --tree --level=2 --icons --git --ignore-glob=node_modules'
alias rm='rm -rf'
alias c='clear'
alias vi="nvim"
alias ..="cd .."
alias e="exit"
alias copy="pbcopy"
alias bc="better-commits"
alias viconf="cd ~/.config/nvim && nvim ."


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

autoload -Uz compinit
compinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

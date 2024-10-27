# Automatically start tmux if not already in a tmux session
#if [ -z "$TMUX" ]; then
    # Create a new session with a unique name (using the date for uniqueness)
    #tmux new-session -s "session_$(date +%Y%m%d_%H%M%S)"
#fi

# Start timer for loading plugins
TIME_START=$(date +%s)


################################ Zinit Setup ################################
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

################################ Enable Powerlevel10k instant prompt ################################
zi ice depth=1; zi light romkatv/powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

################################ Zsh Plugins ################################
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
#zinit light docker/cli

################################ Load completions ################################
autoload -Uz compinit && compinit

################################ History settings ################################
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

################################ Completion styling ################################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

################################ Zsh Snippets ################################
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::node
zinit snippet OMZP::azure
zinit snippet OMZP::command-not-found
zinit snippet OMZP::docker-compose

################################ Add Deno completions to the search path ################################
if [[ ":$FPATH:" != *":/home/shahid/.zsh/completions:"* ]]; then
    export FPATH="/home/shahid/.zsh/completions:$FPATH"
fi

################################ Aliases ################################
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# List files
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias t='tree'
alias t1='tree -L 1'
alias t2='tree -L 2'
# Clear terminal
alias c='clear'

# Grep with color
alias grep='grep --color=auto'

# Show current directory
alias pwd='pwd -P'

# Git shortcuts
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gc='git commit'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gp='git push'
alias gpo='git push origin'
alias gpl='git pull'
alias ga='git add'
alias gb='git branch'
alias gbl='git branch -l'
alias gup='git pull --rebase'
alias gcs='function _gitclone() { git clone git@github.com:shahidshabbir-se/$1.git; }; _gitclone'
alias gch='function _gch() { git clone $1; }; _gch'

# NPM shortcuts
alias ni='npm install'
alias nid='npm install --save-dev'
alias nrun='npm run'
alias nstart='npm start'
alias ntest='npm test'

# Rust Aliases
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'

# Android
export ANDROID_HOME=$HOME/.android/sdk/
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# VPN
function vpnconnect() {
	cd /home/shahid/Documents/vpn && \
	SELECTED_CONFIG="$(fzf --height 40% --reverse --preview 'cat {}' --preview-window=up:10%)" && \
	echo "Selected Configuration: '$SELECTED_CONFIG'" && \
	sudo openvpn --config "$SELECTED_CONFIG" --daemon
}

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dr='docker run'
alias dp='docker pull'

# Edit .zshrc
alias zshrc='nvim ~/.zshrc'

# System aliases
alias c='clear'
#alias fzf='/usr/bin/fzf --preview "bat --style=numbers --color=always --line-range :500 {}; \fi" --preview-window=right:50%'
alias e='exit'
alias bc='better-commits'
alias cat="bat --style=plain"
alias ls='eza --long --icons=always --git --no-time --no-user --no-permissions'
alias nv="nvim"
alias lg="lazygit"
alias pi="sudo pacman -S"
alias pu="sudo pacman -Syu"
alias pc="sudo pacman -Sc"
alias yi="yay -S"
alias yu="yay -Syu"
alias yc="yay -Sc"

################################ Keybindings ################################
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^U' backward-kill-line
bindkey '^K' kill-line
bindkey '^W' backward-kill-word
bindkey '^B' backward-word
bindkey '^F' forward-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^T' transpose-chars
bindkey '^[t' transpose-words
bindkey '^L' clear-screen
bindkey '^Y' yank
bindkey '^[o' execute-named-cmd
bindkey '^@' autosuggest-accept

################################ BAT theme ################################
export BAT_THEME="Solarized"

################################ Zoxide + FZF Setup ################################
eval "$(zoxide init zsh)"
# FZF Default Options
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

################################ NVM setup ################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

################################ GO setup ################################
export PATH=$PATH:~/go/bin

################################ Deno environment setup ################################
. "/home/shahid/.deno/env"

################################ PNPM setup ################################
export PNPM_HOME="/home/shahid/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# End timer and calculate duration
TIME_END=$(date +%s)
TIME_DIFF=$(( TIME_END - TIME_START ))

# Display loading time
if (( TIME_DIFF <= 1 )); then
    echo "🚀 Zsh loaded super fast in less than 1 second!"
elif (( TIME_DIFF < 3 )); then
    echo "⚡ Zsh loaded in $TIME_DIFF seconds!"
else
    echo "🐢 Zsh took $TIME_DIFF seconds to load. Patience is a virtue!"
fi

# pnpm
export PNPM_HOME="/home/shahid/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Automatically start tmux if not already in a tmux session
[ -z "$TMUX" ] && tmux

# Start timer for loading plugins
# TIME_START=$(date +%s)

# >>> Zinit Setup <<<
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz compinit && compinit

# >>> Enable Powerlevel10k instant prompt <<<
zi ice depth=1; zi light romkatv/powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> Zsh Plugins <<<
# docker/cli
for plugin in sudosubin/zsh-poetry zsh-users/zsh-syntax-highlighting zsh-users/zsh-completions conda-incubator/conda-zsh-completion zsh-users/zsh-autosuggestions Aloxaf/fzf-tab; do
  zinit light $plugin
done

# >>> History settings <<<
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# >>> Completion styling <<<
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# >>> Zsh Snippets <<<
for snippet in git sudo archlinux node heroku command-not-found docker-compose; do
  zinit snippet OMZP::$snippet
done

# >>> Add completions to the search path <<<
if [[ ":$FPATH:" != *":/home/shahid/.zsh/completions:"* ]]; then
    export FPATH="/home/shahid/.zsh/completions:$FPATH"
fi

# >>> Aliases <<<
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' ~='cd ~'
alias t='tree' t1='tree -L 1' t2='tree -L 2' t3='tree -L 3'
alias c='clear' kc='nvim ~/.config/kitty/kitty.conf' tc='nvim ~/.config/tmux/tmux.conf' nc='cd ~/.config/nvim && nvim .'
alias bspwm='cd ~/.config/bspwm && nvim .' zz='nvim ~/.zshrc' zh='nvim ~/.zsh_history' zs='source ~/.zshrc'
alias grep='grep --color=auto' pwd='pwd -P'
alias gs='git status' gl='git log --oneline --graph --decorate' gco='git checkout' gc='git commit'
alias gca='git commit -a' gcm='git commit -m' gp='git push' gpo='git push origin' gpl='git pull'
alias ga='git add' gb='git branch' gup='git pull --rebase' gcs='function _gitclone() { git clone git@github.com:shahidshabbir-se/$1.git; }; _gitclone'
alias gch='function _gch() { git clone $1; }; _gch' ggr='git-graph --model git-flow'
alias ni='pnpm install' nd='pnpm install --save-dev' nr='pnpm run dev' ns='pnpm start' nt='pnpm test'
alias d='docker' dc='docker-compose' dps='docker ps' di='docker images' dcu='docker-compose up' dcd='docker-compose down'
alias dr='docker run' dp='docker pull'
alias rm='rm -rf' cd='z' fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window=right:50%'
alias e='exit' bc='better-commits' cat="bat --style=plain"
alias l='eza --icons=always --git -a --no-time --no-user --no-permissions'
alias nv="nvim" pi="sudo pacman -S" pu="sudo pacman -Syu" pc="sudo pacman -Sc"
alias yi="yay -S" yu="yay -Syu" yc="yay -Sc"

# >>> Keybindings <<<
bindkey '^A' beginning-of-line '^E' end-of-line '^U' backward-kill-line '^K' kill-line
bindkey '^W' backward-kill-word '^B' backward-word '^F' forward-word '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward '^D' delete-char '^H' backward-delete-char
bindkey '^T' transpose-chars '^[t' transpose-words '^L' clear-screen '^Y' yank
bindkey '^[o' execute-named-cmd '^@' autosuggest-accept

# >>> VPN <<< 
function vpn_connect() {
    cd /home/shahid/.vpn/config/ && \
    SELECTED_CONFIG="$(fzf --height 40% --reverse --preview 'cat {}' --preview-window=up:10%)" && \
    echo "Selected Configuration: '$SELECTED_CONFIG'"

    # Comment out the block-outside-dns line if present
    sed -i '/block-outside-dns/d' "$SELECTED_CONFIG"

    # Run OpenVPN with the selected config
    sudo openvpn --config "$SELECTED_CONFIG" --daemon --auth-user-pass /home/shahid/.vpn/credentials
}

function vpn_disconnect() {
    sudo pkill openvpn
    echo "VPN connection has been closed."
}

# >>> BAT theme <<<
export BAT_THEME="Catppuccin-Mocha"

# >>> Zoxide + FZF Setup <<<
eval "$(zoxide init zsh)"
# FZF Default Options
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# >>> Custom terminal message <<<
export SUDO_PROMPT="Your love unlocks all doors... and this too: "
command_not_found_handler() {
    echo "💖 'Command not found'? Don't worry, love will find it. Try: sudo $1."
}

# Ensure Zsh uses the custom handler for missing commands
zmodload zsh/parameter
if (( ! ${+functions[command_not_found_handler]} )); then
  functions[command_not_found_handler]="${(z)$(functions command_not_found_handler)}"
fi

# >>> Spicetify <<<
export PATH=$PATH:$HOME/.spicetify

# End timer and calculate duration
TIME_END=$(date +%s)
TIME_DIFF=$(( TIME_END - TIME_START ))

# # Display loading time
# if (( TIME_DIFF <= 1 )); then
#     echo "🚀 Zsh loaded super fast in less than 1 second!"
# elif (( TIME_DIFF < 3 )); then
#     echo "⚡ Zsh loaded in $TIME_DIFF seconds!"
# else
#     echo "🐢 Zsh took $TIME_DIFF seconds to load. Patience is a virtue!"
# fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/shahid/.miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/shahid/.miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/shahid/.miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/shahid/.miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


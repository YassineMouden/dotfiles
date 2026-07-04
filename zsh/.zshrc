if [[ -z "$TMUX" ]]; then
    exec tmux new-session "fastfetch; exec zsh"
fi


# Powerlevel10k Instant Prompt — MUST stay first
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


export TERM="xterm-256color"
export COLORTERM="truecolor"
export EDITOR="nvim"
export VISUAL="nvim"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZSH="$HOME/.oh-my-zsh"

# ================================================
typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.config/emacs/bin"
    $path
)
export PATH

# Oh My Zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE \
       HIST_FIND_NO_DUPS EXTENDED_HISTORY AUTO_CD

# Tool Configurations
export DOOMDIR="$HOME/.config/doom"

[[ -f "$XDG_CACHE_HOME/zoxide-init.zsh" ]] && source "$XDG_CACHE_HOME/zoxide-init.zsh" \
    || eval "$(zoxide init zsh)"
alias cd="z"

[[ -f "$XDG_CACHE_HOME/fzf-init.zsh" ]] && source "$XDG_CACHE_HOME/fzf-init.zsh" \
    || eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir()  { fd --type=d --hidden --exclude .git . "$1"; }

export FZF_DEFAULT_OPTS="--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f,fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f,info:#83a598,prompt:#b8bb26,pointer:#fb4934,marker:#fb4934,spinner:#83a598,header:#8ec07c"

export BAT_THEME="gruvbox-dark"

export PATH="$PATH:$(go env GOPATH)/bin"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true

# Powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Aliases
alias ls="lsd -F"
alias ll="lsd -lahF"
alias la="lsd -AF"
alias lg="lsd --group-dirs=first"
alias tree="lsd --tree"

alias ..="cd .."
alias ...="cd ../.."

alias v="nvim"
alias vi="nvim"

alias reload="source ~/.zshrc"
alias c="clear"

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"

alias mkdir="mkdir -pv"
alias grep="grep --color=auto"
alias path='echo "$PATH" | tr ":" "\n"'
alias weather="curl wttr.in"
alias dus="du -sh * | sort -h"

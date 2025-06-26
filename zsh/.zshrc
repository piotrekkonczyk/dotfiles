# -------------------------------------------------------------------
# Interactive Initialization (must come before instant prompt)
# -------------------------------------------------------------------

# Load SSH keys only in interactive sessions
if [[ -o interactive ]] && [[ -z "$SSH_AUTH_SOCK" ]]; then
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# -------------------------------------------------------------------
# Powerlevel10k Instant Prompt
# -------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -------------------------------------------------------------------
# Zinit Plugin Manager
# -------------------------------------------------------------------
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}Installing Zinit plugin manager...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{34}Installation successful.%f" || \
        print -P "%F{160}Installation failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit

# -------------------------------------------------------------------
# Plugin Configuration
# -------------------------------------------------------------------

# Turbo-loaded plugins (async)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Load vi-mode early to avoid keybinding conflicts
zinit ice wait"0" lucid
zinit light jeffreytse/zsh-vi-mode

# FZF-Tab (load after completions)
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# Other plugins
zinit light MichaelAquilina/zsh-you-should-use

# Oh My Zsh snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
zinit snippet OMZP::python

# Powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -------------------------------------------------------------------
# Environment Variables
# -------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim
export TERMINAL=alacritty
export BROWSER=com.brave.Browser

# Custom paths 
export PATH="$PATH:/opt/nvim/" # Nvim
export PATH="$PATH:$HOME/.local/bin:$PATH" # Poetry

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -------------------------------------------------------------------
# FZF Configuration
# -------------------------------------------------------------------
if [[ -x "$(command -v fzf)" ]]; then
  export FZF_DEFAULT_OPTS="
    --info=inline-right
    --ansi
    --layout=reverse
    --border=rounded
    --color=border:#27a1b9
    --color=fg:#c0caf5
    --color=gutter:#16161e
    --color=header:#ff9e64
    --color=hl+:#2ac3de
    --color=hl:#2ac3de
    --color=info:#545c7e
    --color=marker:#ff007c
    --color=pointer:#ff007c
    --color=prompt:#2ac3de
    --color=query:#c0caf5:regular
    --color=scrollbar:#27a1b9
    --color=separator:#ff9e64
    --color=spinner:#ff007c"
fi

# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------
alias ls='eza --icons=always --long'
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vim="nvim"
alias reload-zsh="source ~/.zshrc"

# -------------------------------------------------------------------
# Shell Options
# -------------------------------------------------------------------
setopt autocd              # Change directory by typing name
setopt correct             # Auto-correct mistakes
setopt interactivecomments # Allow comments in interactive mode
setopt magicequalsubst     # Enhanced filename expansion
setopt nonomatch           # Hide pattern match errors
setopt notify              # Immediate background job status
setopt numericglobsort     # Numeric filename sorting
setopt promptsubst         # Command substitution in prompt

# -------------------------------------------------------------------
# History Configuration
# -------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory       # Append to history file
setopt sharehistory        # Share history across sessions
setopt histignorespace     # Ignore commands starting with space
setopt histignorealldups   # Ignore duplicate commands
setopt histsavenodups      # Save only unique commands
setopt histfindnodups      # Skip duplicates in search

# -------------------------------------------------------------------
# Completion Styles
# -------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colorize
zstyle ':completion:*' menu select # Interactive menu
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# -------------------------------------------------------------------
# tmux Git Autofetch
# -------------------------------------------------------------------
tmux-git-autofetch() {
  [[ -n "$TMUX" ]] || return
  local script_path="$HOME/.tmux/plugins/tmux-git-autofetch/git-autofetch.tmux"
  [[ -x "$script_path" ]] || return
  
  {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    "$script_path" --current
  } &>> "$HOME/.tmux_git_autofetch.log" &!
}

if [[ -n "$TMUX" ]]; then
  add-zsh-hook precmd tmux-git-autofetch
  add-zsh-hook chpwd tmux-git-autofetch
fi

# -------------------------------------------------------------------
# Maintenance Commands
# -------------------------------------------------------------------
zinit-self-update() {
  zinit self-update
  zinit update --parallel
}

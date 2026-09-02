# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ -z "$XDG_CONFIG_HOME" ] ; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z "$XDG_DATA_HOME" ] ; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z "$XDG_CACHE_HOME" ] ; then
    export XDG_CACHE_HOME="$HOME/.cache"
fi
### PATH
if [ -d "$HOME/.bin" ] ;
  then PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/bin" ] ;
  then PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/Applications" ] ;
  then PATH="$HOME/Applications:$PATH"
fi

if [ -d "/var/lib/flatpak/exports/bin/" ] ;
  then PATH="/var/lib/flatpak/exports/bin/:$PATH"
fi


# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"



# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi


# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

#zinit light zsh-users/zsh-syntax-highlighting
#zinit light zsh-users/zsh-completions
#zinit light zsh-users/zsh-autosuggestions
zinit wait lucid for \
    zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# Load completion definitions before initializing Zsh's completion system.
zinit light zsh-users/zsh-completions

autoload -Uz compinit
compinit

# fzf-tab must be loaded after compinit.
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
#zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found
#zinit snippet OMZP::asdf

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

### EXPORT
export TERM="xterm-256color"                      # getting proper colors
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
# History
HISTSIZE=50000
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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'




## ALIASES
#neovim
alias vim="nvim"
alias vi="nvim"
alias neovim="nvim"
# Changing "ls" to "exa"
alias la='eza -al --color=always --group-directories-first --icons' 
alias ls='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.='eza -al --icons --color=always --group-directories-first | egrep "^\."'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
#alias egrep='egrep --color=auto'
#alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
alias tree='eza -T'

# Shell integrations
if (( $+commands[fzf] )); then
  eval "$(fzf --zsh)"
  # fzf's integration also binds Tab; keep fzf-tab as the completion frontend.
  bindkey '^I' fzf-tab-complete
fi
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

#. ~/.asdf/plugins/java/set-java-home.zsh 
#. ~/.asdf/installs/rust/1.82.0/env 
#. ~/.asdf/plugins/golang/set-env.zsh 


export _JAVA_AWT_WM_NONREPARENTING=1
#export DOCKER_HOST=unix:///run/user/1000/docker.sock
#nodejs
#-- export PATH=~/.npm-global/bin:$PATH
#rust
#-- . "$HOME/.cargo/env"

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
#java
export JAVA_HOME=~/Applications/jdk21.0.11/
export PATH=$JAVA_HOME/bin:$PATH


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fnm
FNM_PATH="/home/dtutila/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

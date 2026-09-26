# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Salesforce CLI: file-based key instead of GNOME Keyring (see uwsm/env-hyprland)
export SF_USE_GENERIC_UNIX_KEYCHAIN=true

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

# Plugins are pinned to reviewed upstream commits. Review changes before bumping
# a pin, and don't run `zinit self-update`. See docs/zsh-plugin-pins.md.
ZINIT_COMMIT=98bcb79c3d7aae25a81e00e9795ebf7042e2bd6e # zinit v3.16.0

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
   git -C "$ZINIT_HOME" checkout -q "$ZINIT_COMMIT"
fi
[[ "$(<"$ZINIT_HOME/.git/HEAD")" == "$ZINIT_COMMIT" ]] ||
  print -P "%F{yellow}zinit is not at the pinned commit ${ZINIT_COMMIT:0:12}%f"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k (the pin also pins the gitstatusd binary sha256)
zinit ice ver"3308262dfbd743b6e1d3956a2b5572f7a049d692"
zinit light romkatv/powerlevel10k

# fast-syntax-highlighting downloads secondary_theme.zsh from its master branch
# and sources it when the file is missing; seed it from the pinned checkout.
typeset -g FAST_WORK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fsh"
zinit wait lucid for \
    ver"4672ad5dd9ad68a7effc1476d65afb7c584ce2b3" \
    atinit'[[ -e $FAST_WORK_DIR/secondary_theme.zsh ]] || { mkdir -p $FAST_WORK_DIR && cp share/free_theme.zsh $FAST_WORK_DIR/secondary_theme.zsh; }' \
    zdharma-continuum/fast-syntax-highlighting \
    ver"85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5" \
    atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
    ver"14c8d2e0ffaee98f2df9850b19944f32546fdea5" \
    atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down; bindkey '^[OA' history-substring-search-up; bindkey '^[OB' history-substring-search-down" \
    zsh-users/zsh-history-substring-search

# Load completion definitions before initializing Zsh's completion system.
zinit ice ver"8cd3bd78e8b1f17271cfdd8269074e5557d8d7b8"
zinit light zsh-users/zsh-completions

autoload -Uz compinit
compinit

# fzf-tab must be loaded after compinit.
zinit ice ver"24105b15714bfec37989ed5c5b6e60f572253019"
zinit light Aloxaf/fzf-tab

# Oh My Zsh snippets, pinned by commit in the raw URL
zinit ice id-as"omz-git"
zinit snippet https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/91ad6c5c4ce7727500662e093e41ac421527e23a/plugins/git/git.plugin.zsh
zinit ice id-as"omz-command-not-found"
zinit snippet https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/a8afe14b93051178264db802d964c7f31a552e8d/plugins/command-not-found/command-not-found.plugin.zsh

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
bindkey '^[[13;2u' accept-line                # kitty sends Shift+Enter as CSI-u

### EXPORT
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
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Directory navigation
setopt autocd auto_pushd pushd_ignore_dups

# Man pages through bat; -c keeps groff from emitting SGR codes that col leaves as junk
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi




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

# System helpers
alias make="make -j$(nproc)"
alias jctl='journalctl -p 3 -xb'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias ip='ip -color=auto'
alias tarnow='tar -acf'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo dnf upgrade --refresh'
alias cleanup='sudo dnf autoremove'
alias rip='rpm -qa --last | head -50'
alias big="rpm -qa --qf '%{SIZE}\t%{NAME}\n' | sort -n | tail -30"
open() { xdg-open "$@" >/dev/null 2>&1 &! }
# Remote hosts usually lack kitty's terminfo
[[ "$TERM" == xterm-kitty ]] && alias ssh='TERM=xterm-256color ssh'

# Shell integrations
if (( $+commands[fzf] )); then
  eval "$(fzf --zsh)"
  # fzf's integration also binds Tab; keep fzf-tab as the completion frontend.
  bindkey '^I' fzf-tab-complete
fi

#. ~/.asdf/plugins/java/set-java-home.zsh 
#. ~/.asdf/installs/rust/1.82.0/env 
#. ~/.asdf/plugins/golang/set-env.zsh 


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

alias cursor='cursor --password-store="gnome-libsecret"'

# zoxide must be initialized last
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

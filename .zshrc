# Add Homebrew to PATH and its completions to FPATH
if [ -x "/opt/homebrew/bin/brew" ]; then
    export HOMEBREW_AUTO_UPDATE_SECS="86400"
    # For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

    export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d $ZINIT_HOME ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# zinit ice depth=1; zinit light romkatv/powerlevel10k

# Install zsh plugins
# zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# # zinit light chmouel/fzf-select-file

# zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'
# zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git-commit/git-commit.plugin.zsh'
# zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/rust/rust.plugin.zsh'

# Load completions
autoload -U compinit && compinit
if type ruff &>/dev/null; then
    eval "$(ruff generate-shell-completion zsh)"
fi
if type taplo &>/dev/null; then
    eval "$(taplo completions zsh)"
fi
if type uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

# Enable starship
eval "$(starship init zsh)"
source $HOME/.config/zsh/transient-prompt.sh

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Highlighting colors
source ~/.config/zsh/tokyo-night-zsh-syntax-highlighting.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'

# Aliases
alias ls="eza --color=always --icons=always"
alias cat="bat --color=always"

# Install zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zinit light chmouel/fzf-select-file

zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'
zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git-commit/git-commit.plugin.zsh'
zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/rust/rust.plugin.zsh'

zinit snippet 'https://github.com/robbyrussell/oh-my-zsh/raw/master/plugins/git/git.plugin.zsh'

zinit load 'zsh-users/zsh-history-substring-search'
# zinit ice wait atload '_history_substring_search_config'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

eval "$(fzf --zsh)"

# Start the-fuck, or better the rust rewrite fixit
eval "$(fixit init --name fuck zsh)"

# De-dupe PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

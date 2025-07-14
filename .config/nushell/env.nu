# Inspired from
# https://github.com/webpro/dotfiles/blob/main/system/.env

$env.EDITOR = "code"
$env.VISUAL = "code"

# XDG Base Directory Specification (https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
$env.XDG_CACHE_HOME = $"($nu.home-path)/.cache"
$env.XDG_CONFIG_HOME = $"($nu.home-path)/.config"
$env.XDG_DATA_HOME = $"($nu.home-path)/.local/share"
$env.XDG_STATE_HOME = $"($nu.home-path)/.local/state"
$env.XDG_RUNTIME_DIR = $"($nu.home-path)/.local/runtime" # macOS does not have session lifetime directories; alt: `~/Library/Caches`

# Prefer US English and use UTF-8
$env.LC_ALL = "en_US.UTF-8"
$env.LANG = "en_US"

# Carapace init
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
mkdir ~/.cache/carapace
/opt/homebrew/bin/carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

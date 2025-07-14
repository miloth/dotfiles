$env.config.show_banner = false

$env.HOMEBREW_AUTO_UPDATE_SECS = "86400"
# Do the same as `brew shellenv`
$env.HOMEBREW_PREFIX = "/opt/homebrew"
$env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/opt/homebrew"

for p in [
    "/usr/local/bin",
    $"($nu.home-path)/.local/bin",
    "/opt/homebrew/sbin",
    "/opt/homebrew/bin",
] {
    if ( $env.PATH not-has $p) {
        $env.PATH ++= [ $p ]
    }
}

source $"($nu.home-path)/.cargo/env.nu"

source ~/.cache/carapace/init.nu

$env.PATH = $env.PATH | uniq

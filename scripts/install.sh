#!/usr/bin/env zsh

# cSpell: ignore autohide clmv Flwv gbzzzz gpgsign icnv installondemand launchanim Nlsv pmux setusingnetworktime
# cSpell: ignore showhidden ShowPathbar signingkey tilesize tlsv1 wvous

SCRIPT_DIR="${0:A:h}"

function xcode-select-install () {
    # Adapted from:
    # https://developer.apple.com/forums/thread/698954?answerId=723615022#723615022
    echo "Checking Command Line Tools for Xcode"
    # Only run if the tools are not installed yet
    # To check that try to print the SDK path
    xcode-select -p &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Command Line Tools for Xcode not found. Installing from softwareupdate…"
        # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
        softwareupdate -i "$PROD" --verbose;
    else
        echo "Command Line Tools for Xcode already installed."
    fi
}

function rosetta () {
    # Source:
    # https://apple.stackexchange.com/a/464165
    if [[ `uname -m` != "arm64" ]] ; then
        echo "not arm64"
    else
        if ! (arch -arch x86_64 uname -m > /dev/null) ; then
            softwareupdate --install-rosetta --agree-to-license
        else
            echo "arm64: Rosetta already installed"
        fi
    fi
}

function homebrew () {
    # Install Homebrew if not available
    if ! command -v "/opt/homebrew/bin/brew" &>/dev/null; then
        echo "Homebrew not installed. Installing Homebrew."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
    # Attempt to set up Homebrew PATH automatically for this session
    if ! command -v brew &>/dev/null; then
        if [ -x "/opt/homebrew/bin/brew" ]; then
            # For Apple Silicon Macs
            echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
            export PATH="/opt/homebrew/bin:$PATH"
        fi
        # Verify brew is now accessible
        if ! command -v brew &>/dev/null; then
            echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
            exit 1
        fi
    fi
    # Update Homebrew and Upgrade any already-installed formulae
    brew update
    brew upgrade
    brew upgrade --cask
    brew bundle install --file $SCRIPT_DIR/Brewfile --upgrade
    brew cleanup
}

function finder-setup () {
    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    # Finder: allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true
    # Keep folders on top when sorting by name
    # defaults write com.apple.finder _FXSortFoldersFirst -bool true
    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    # Disable the warning when changing a file extension
    # defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # Always open everything in Finder's list view.  Use list view in all Finder windows by default. Other codes: `icnv`, `clmv`, `Flwv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

    killall Finder
}

function dock_setup () {
    # Control which apps end up on the Dock
    dockutil --no-restart --remove all
    dockutil --no-restart --add "/Applications/Vivaldi.app"
    dockutil --no-restart --add "/Applications/Visual Studio Code.app"
    dockutil --no-restart --add "/Applications/WezTerm.app"
    dockutil --no-restart --add "/Applications/Signal.app"
    dockutil --no-restart --add "/Applications/Spotify.app"
    dockutil --no-restart --add "/System/Applications/System Settings.app"
    # Folders next to the Trash Can
    dockutil --no-restart --add "/Volumes/Vault/Downloads"

    # Put dock on the left
    defaults write com.apple.dock orientation left
    # Smaller size
    defaults write com.apple.dock tilesize -int 48
    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true
    # Don’t animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true
    # Disable hot corners
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-br-corner -int 0
    # Don't show recently used applications in the Dock
    defaults write com.apple.dock show-recents -bool false

    killall Dock
}

function localization () {
    LANGUAGES=(en it)
    LOCALE="en_US@rg=gbzzzz"
    MEASUREMENT_UNITS="Centimeters"

    # Set language and text formats
    defaults write NSGlobalDomain AppleLanguages -array ${LANGUAGES[@]}
    defaults write NSGlobalDomain AppleLocale -string "$LOCALE"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "$MEASUREMENT_UNITS"
    defaults write NSGlobalDomain AppleMetricUnits -bool true

    # Using systemsetup might give Error:-99, can be ignored (commands still work)
    # systemsetup manpage: https://ss64.com/osx/systemsetup.html

    # Set the time zone
    sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
    sudo systemsetup -setusingnetworktime on
}

function rustup-install () {
    if ! which rustup &>/dev/null; then
        echo "Select a custom rustup installation without adding to PATH"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        echo "Rust is already installed."
    fi
}

function run-stow () {
    cd ~/dotfiles
    stow .
    cd $SCRIPT_DIR

    source ~/.zshenv
    source ~/.zshrc
}

function git-credentials () {
    echo "Setting up Git credentials..."
    git config --global user.name $USER
    git config --global user.email "$USER@users.noreply.github.com"
    git config --global init.defaultBranch main
    gh auth login
    git config --global gpg.format ssh
    git config --global commit.gpgsign true
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
    git config --global user.signingkey ~/.ssh/id_ed25519.pub
}

function vscode-settings () {
    ln -sf "$HOME/.config/Code/User/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

    INSTALLED_EXTENSIONS=$(code --list-extensions)
    while IFS= read -r line; do
        if echo "$INSTALLED_EXTENSIONS" | grep -qi "^$line$"; then
            echo "$line is already installed. Skipping..."
        else
            echo "Installing $line..."
            code --install-extension "$line"
        fi
    done < "$SCRIPT_DIR/vscode-extensions.txt"
    echo "VS Code extensions installed."
}

function add-and-configure-nushell () {
    # Check from here:
    # https://askubuntu.com/a/1422254
    if ! grep -wq "$(which nu)" /etc/shells; then
        which nu | sudo tee -a /etc/shells
    fi
    # chsh -s "$(which nu)"

    ln -sf "$HOME/.config/nushell/config.nu" "$HOME/Library/Application Support/nushell/config.nu"
    ln -sf "$HOME/.config/nushell/env.nu" "$HOME/Library/Application Support/nushell/env.nu"
}

function tmux-config () {
    # Install Tmux Plugin Manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        echo "Tmux Plugin Manager is already installed."
    fi
    echo "Install pmux plugins by pressing <prefix> + I (capital I)"
    echo "Then run the following command to source the config:"
    echo "tmux source ~/.tmux.conf"
}

function main () {
    echo "🛤️ SOURCING ENV VARIABLES"
    source $SCRIPT_DIR/../.zshenv

    echo "🍎 XCODE-SELECT"
    xcode-select-install

    echo "🌹 ROSETTA 2"
    rosetta

    echo "🍺 HOMEBREW"
    homebrew

    echo "📁 FINDER, DOCK AND LOCALIZATION"
    finder-setup
    dock_setup
    localization

    echo "🦀 RUST"
    rustup-install

    echo "📌 STOW"
    run-stow

    echo "🔐 GIT CREDENTIALS"
    git-credentials

    echo "📝 VSCODE SETTINGS"
    vscode-settings

    echo "🐚 CONFIGURE NUSHELL"
    add-and-configure-nushell

    echo "TMUX"
    tmux-config
}

main

#!/usr/bin/env zsh

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
}

function rustup-install () {
    if ! which rustup &>/dev/null; then
        echo "Select a custom rustup installation without adding to PATH"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        echo "Rust is already installed."
    fi
}

function default-nushell () {
    # Check from here:
    # https://askubuntu.com/a/1422254
    if ! grep -wq "$(which nu)" /etc/shells; then
        which nu | sudo tee -a /etc/shells
    fi
    chsh -s "$(which nu)"

    ln -sf "$HOME/.config/nushell/config.nu" "$HOME/Library/Application Support/nushell/config.nu"
    ln -sf "$HOME/.config/nushell/env.nu" "$HOME/Library/Application Support/nushell/env.nu"
}

function main () {
    echo "🛤️ SOURCING ENV VARIABLES"
    source $SCRIPT_DIR/../.env

    echo "🍎 XCODE-SELECT"
    xcode-select-install

    echo "🌹 ROSETTA 2"
    rosetta

    echo "🍺 HOMEBREW"
    homebrew

    echo "🦀 RUST"
    rustup-install

    echo "📌 STOW"
    run-stow

    echo "🔐 GIT CREDENTIALS"
    git-credentials

    echo "📝 VSCODE SETTINGS"
    vscode-settings

    echo "🐚 DEFAULT NUSHELL"
    default-nushell
}

main

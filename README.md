# Miloth's macOS Dotfiles

## Quick Start

Steps:

- Clone the repo.
- Double check the:
  - Apps to be installed in `scripts/Brewfile`.
  - VSCode extensions in `scripts/vscode-extensions.txt`.
- Run `scripts/install.sh`, prompting the `sudo` password when requested.
- `cd` to the root of this project if not already.
- Run `stow .`.

If you update the `stow` file list with `stow . --restow`.

## Still Manual

- Login to Vivaldi and other apps.
- Disable Spotlight's shortcut and assign it to RayCast.

## Additional Info

This is my choice of dotfiles. The setup leverages:

- [`stow`](https://www.gnu.org/software/stow/) to symlink config files, making it easy to version them with `git`.
- [Homebrew](https://brew.sh) to install all the required applications, cli tools and fonts.

The setup will:

- Configure Finder and the Dock.
- Make Vivaldi the default browser.
- Login to GitHub.
- Preinstall a suite of dev tools, like Rust, Python (using `uv`), octave (for a sane calculator environment).
- Wezterm as the terminal emulator of choice, configure `zsh` and `nushell` paths and environment variables.
- Nerdfonts!
- VSCode configured with settings and extensions.
- RayCast instead of Spotlight.

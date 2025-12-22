#!/bin/bash

set -e

echo "🚀 Starting macOS setup..."

check_xcode_tools() {
    if ! command -v xcode-select &> /dev/null; then
        echo "Installing Xcode Command Line Tools"
        xcode-select --install
    else
        echo "Xcode Command Line Tools already installed"
    fi
}
check_xcode_tools

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "Homebrew already installed"
    fi

    # Update Homebrew
    brew update --quiet && brew upgrade --quiet
}
install_homebrew

# Dotfiles Setup
echo "📁 Setting up dotfiles..."
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/43curious/.dotfiles "$DOTFILES_DIR"
else
    echo "Dotfiles already exist. Pulling latest..."
    cd "$DOTFILES_DIR" && git pull || true
fi

# Install packages from Brewfile
echo "📦 Installing packages from Brewfile..."
brew bundle install --file=~/.dotfiles/brewfile

# Cleanup packages not in Brewfile
echo "🧹 Cleaning up packages not in Brewfile..."
brew bundle cleanup --force --file=~/.dotfiles/brewfile

# macOS System Settings
echo "⚙️  Configuring macOS settings..."

# Dock settings
defaults write com.apple.dock autohide -bool true # Dock auto-hide
defaults write com.apple.dock autohide-delay -float 0.0 # Dock hides as fast as possible
defaults write com.apple.dock autohide-time-modifier -float 0.0
defaults write com.apple.dock show-recents -bool false # Disabled recent apps

# Set persistent apps in Dock
defaults write com.apple.dock persistent-apps -array \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Helium.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Ghostty.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

killall Dock

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true # Show filepath 
defaults write com.apple.finder ShowStatusBar -bool true # Show status bar 
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder CreateDesktop -bool false # No desktop icons or folders
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # Default new window to list view
defaults write com.apple.finder ShowRecentTags -bool false # Hide color tags in 
defaults write com.apple.finder NewWindowTarget -string "PfHm" # Add the home folder as the default for a new window
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}" # Add the home folder as the default for a new window
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false # Hide external drives, 
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false # Hide internal drives
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false # Hide mounted servers
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false # Hide removable media

killall Finder

# Global settings
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark" # System theme to dark mode
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false # Disable natural scrolling
defaults write -g NSReduceMotionEnabled -bool TRUE # Enable reduced motion
defaults write NSGlobalDomain _HIHideMenuBar -bool true # Hide menu bar

# Oh My Zsh Setup
echo "🐚 Setting up Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed"
fi

# Deletes current .zshrc to avoid conflicts
rm -rf ~/.zshrc

# Stow dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    echo "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    for dir in zsh git nvim ghostty skhd; do
        if [ -d "$dir" ]; then
            stow --adopt -v "$dir" -t "$HOME" || echo "Stow failed for $dir"
        fi
    done
fi

# Create custom Oh My Zsh theme
echo "🎨 Creating custom zsh theme..."
mkdir -p "$HOME/.oh-my-zsh/custom/themes"
cat << 'EOF' > "$HOME/.oh-my-zsh/custom/themes/castro.zsh-theme"
PROMPT="%(?:%{$fg_bold[white]%}%1{➜%} :%{$fg_bold[white]%}%1{➜%} ) %{$fg[white]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[white]%}git:(%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]%}) %{$fg[white]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[white]%})"
EOF

# Create Development directory
echo "📂 Creating Development directory..."
mkdir -p "$HOME/Development"

# Set zsh as default shell if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# Change the hostname to maverick
sudo scutil --set ComputerName "maverick"
sudo scutil --set LocalHostName "maverick"
sudo scutil --set HostName "maverick"

# Start skhd service
skhd --start-service

echo "✅ Setup complete! Please restart your terminal and source .zshrc"
echo "Note: You may need to log out and back in for all changes to take effect."

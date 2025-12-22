#!/bin/bash

set -e

# Removes all pinned apps from the dock
defaults write com.apple.dock persistent-apps -array

# Dock settings
defaults write com.apple.dock autohide -bool true # Dock auto-hide
defaults write com.apple.dock autohide-delay -float 0.0 # Dock hides as fast as possible
defaults write com.apple.dock autohide-time-modifier -float 0.0
defaults write com.apple.dock show-recents -bool false # Disabled recent apps

# Set persistent apps in Dock
defaults write com.apple.dock persistent-apps -array \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Firefox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/DaVinci Resolve.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

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


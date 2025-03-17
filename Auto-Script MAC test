#!/bin/bash
# Auto-Script Installer for macOS using Homebrew and Custom Application Installer

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew is not installed. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to install applications via Homebrew
install_apps() {
    echo "Updating Homebrew..."
    brew update

    # Standard Applications
    brew install --cask steam
    brew install --cask adobe-acrobat-reader
    brew install --cask microsoft-teams
    brew install --cask firefox
    brew install --cask discord
    brew install --cask google-chrome
    brew install --cask notepadqq
    brew install openjdk@8
}

# Function to install the custom capstone app
install_capstone_app() {
    APP_NAME="MyCapstoneApp"
    APP_URL="https://example.com/path-to-app.dmg" # Replace with actual URL

    echo "Downloading $APP_NAME..."
    curl -L -o ~/Downloads/$APP_NAME.dmg "$APP_URL"

    echo "Mounting the DMG file..."
    hdiutil attach ~/Downloads/$APP_NAME.dmg -nobrowse

    echo "Copying application to /Applications/"
    cp -R "/Volumes/$APP_NAME/$APP_NAME.app" /Applications/

    echo "Ejecting DMG..."
    hdiutil detach "/Volumes/$APP_NAME"

    echo "Cleaning up installation files..."
    rm ~/Downloads/$APP_NAME.dmg

    echo "$APP_NAME installation complete!"
}

# Main Execution
echo "Starting Auto-Script Installer for macOS..."
check_homebrew
install_apps
install_capstone_app

echo "All applications installed successfully!"


#!/bin/bash

set -e

# ============================================================
# Sway Config Installer
# Arch Linux
# ============================================================

REPO_URL="https://github.com/tester-908/sway-config.git"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "      Sway Environment Installer"
echo "======================================"
echo

# ------------------------------------------------------------
# Check Arch Linux
# ------------------------------------------------------------

if [ ! -f /etc/arch-release ]; then
    echo "ERROR: This installer is intended for Arch Linux."
    exit 1
fi

# ------------------------------------------------------------
# Check sudo
# ------------------------------------------------------------

if ! command -v sudo >/dev/null 2>&1; then
    echo "ERROR: sudo is required."
    exit 1
fi

# ------------------------------------------------------------
# Update system
# ------------------------------------------------------------

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# ------------------------------------------------------------
# Install base packages
# ------------------------------------------------------------

echo
echo "==> Installing packages..."

sudo pacman -S --needed --noconfirm \
    waybar \
    wofi \
    foot \
    kitty \
    nwg-drawer \
    nwg-bar \
    wl-mirror \
    imagemagick \
    playerctl \
    swaylock \
    pacman-contrib \
    pavucontrol \
    firefox \
    nautilus \
    grim \
    slurp \
    wl-clipboard \
    jq \
    polkit-gnome \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    wireplumber \
    brightnessctl \
    asciiquarium \
    git \
    stow \
    wget \
    curl \
    nano \
    bat \
    imv \
    networkmanager \
    bluez \
    bluez-utils \
    alsa-utils \
    linux-headers \
    noto-fonts-emoji \
    otf-font-awesome \
    cmake \
    openssh \
    btop \
    base-devel \
    gdm \
    swaybg

# ------------------------------------------------------------
# Install paru
# ------------------------------------------------------------

if ! command -v paru >/dev/null 2>&1; then
    echo
    echo "==> Installing paru..."

    TEMP_DIR="$(mktemp -d)"

    git clone https://aur.archlinux.org/paru.git "$TEMP_DIR/paru"

    cd "$TEMP_DIR/paru"
    makepkg -si --noconfirm

    cd "$HOME"
    rm -rf "$TEMP_DIR"
else
    echo "==> paru already installed."
fi

paru -S --needed --noconfirm swayfx

# ------------------------------------------------------------
# Install VS Code
# ------------------------------------------------------------

echo
echo "==> Installing Visual Studio Code..."

paru -S --needed --noconfirm visual-studio-code-bin

# ------------------------------------------------------------
# VS Code extensions
# ------------------------------------------------------------

echo
echo "==> Installing VS Code extensions..."

VSCODE_EXTENSIONS=(
    "rocketseat.theme-omni"
    "ms-vscode.cpptools"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "golang.go"
    "ms-vscode.cmake-tools"
    "steoates.autoimport"
)

for extension in "${VSCODE_EXTENSIONS[@]}"; do
    code --install-extension "$extension" --force
done

# ------------------------------------------------------------
# Clone/update dotfiles
# ------------------------------------------------------------

echo
echo "==> Installing Sway configuration..."

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Existing repository found."
    echo "==> Updating repository..."

    git -C "$DOTFILES_DIR" pull
else
    echo "==> Cloning repository..."

    rm -rf "$DOTFILES_DIR"
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# ------------------------------------------------------------
# Create directories
# ------------------------------------------------------------

echo
echo "==> Creating directories..."

mkdir -p "$HOME/.config/sway/scripts"
mkdir -p "$HOME/.config/themes/dark"
mkdir -p "$HOME/.config/themes/light"
mkdir -p "$HOME/.config/themes/wallpapers"
mkdir -p "$HOME/.config/foot"
mkdir -p "$HOME/.images"

# ------------------------------------------------------------
# Install Sway config & settings
# ------------------------------------------------------------

echo
echo "==> Installing Sway config..."

cp "$DOTFILES_DIR/config" "$HOME/.config/sway/config"
cp "$DOTFILES_DIR/settings.json" "$HOME/.config/sway/settings.json"

# Install Foot
cp "$DOTFILES_DIR/foot/foot.ini" "$HOME/.config/foot/foot.ini"

# ------------------------------------------------------------
# Install themes
# ------------------------------------------------------------

echo
echo "==> Installing themes..."

cp -r "$DOTFILES_DIR/themes/dark/." "$HOME/.config/themes/dark/"
cp -r "$DOTFILES_DIR/themes/light/." "$HOME/.config/themes/light/"
cp "$DOTFILES_DIR/themes/switch-theme.sh" "$HOME/.config/themes/switch-theme.sh"
chmod +x "$HOME/.config/themes/switch-theme.sh"

if [ ! -L "$HOME/.config/themes/current" ]; then
    rm -rf "$HOME/.config/themes/current"
    ln -s "$HOME/.config/themes/dark" "$HOME/.config/themes/current"
fi

for component in wofi nwg-drawer nwg-bar; do
    rm -rf "$HOME/.config/$component"
    ln -s "$HOME/.config/themes/current/$component" "$HOME/.config/$component"
done

# ------------------------------------------------------------
# Install scripts
# ------------------------------------------------------------

echo
echo "==> Installing scripts..."

cp -r "$DOTFILES_DIR/scripts/." "$HOME/.config/sway/scripts/"
chmod +x "$HOME/.config/sway/scripts/"*

# ------------------------------------------------------------
# Install wallpaper
# ------------------------------------------------------------

echo
echo "==> Installing wallpaper..."

cp "$DOTFILES_DIR/wallpaper.jpg" \
   "$HOME/.images/wallpaper.jpg"

if [ -z "$(ls -A "$HOME/.config/themes/wallpapers" 2>/dev/null)" ]; then
    cp "$DOTFILES_DIR/wallpaper.jpg" \
       "$HOME/.config/themes/wallpapers/wallpaper.jpg"
fi

# ------------------------------------------------------------
# Enable services
# ------------------------------------------------------------

echo
echo "==> Enabling services..."

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

# ------------------------------------------------------------
# Bash
# ------------------------------------------------------------

echo
echo "==> Setting Bash as default shell..."

if [ "$SHELL" != "/bin/bash" ]; then
    chsh -s /bin/bash
fi

# Install Bash configuration
cp "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

# ------------------------------------------------------------
# GDM
# ------------------------------------------------------------

echo
echo "==> Enabling GDM login screen..."

sudo systemctl enable gdm.service

# ------------------------------------------------------------
# Sway config check
# ------------------------------------------------------------

echo
echo "==> Checking Sway configuration..."

if sway -C -c "$HOME/.config/sway/config"; then
    echo "Sway configuration: OK"
else
    echo
    echo "WARNING: Sway configuration has errors."
    echo "Run:"
    echo
    echo "    sway -C -c ~/.config/sway/config"
    echo
fi

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

echo
echo "======================================"
echo "       Installation complete!"
echo "======================================"
echo
echo "Installed:"
echo "  Swayfx"
echo "  Waybar"
echo "  Wofi"
echo "  nwg-drawer"
echo "  nwg-bar"
echo "  Foot"
echo "  Kitty"
echo "  Firefox"
echo "  Nautilus"
echo "  PipeWire"
echo "  Bluetooth"
echo "  NetworkManager"
echo "  Asciiquarium"
echo "  wl-mirror"
echo "  ImageMagick"
echo "  VS Code"
echo "  paru"
echo
echo "Your configuration is located at:"
echo "  ~/.config/sway/config"
echo "  ~/.config/sway/settings.json"
echo
echo "Themes:"
echo "  ~/.config/themes/"
echo
echo "Scripts:"
echo "  ~/.config/sway/scripts/"
echo
echo "Wallpapers:"
echo "  ~/.config/themes/wallpapers/ (add more wallpapers here)"
echo
echo "IMPORTANT:"
echo "Your monitor configuration is specific to your hardware."
echo "Check the 'output' lines in ~/.config/sway/config and"
echo "~/.config/sway/settings.json before using this setup on another computer."
echo
echo "A reboot or new Sway session is recommended."
echo

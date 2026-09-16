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
    sway \
    waybar \
    wofi \
    kitty \
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
    zsh \
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
    base-devel

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

mkdir -p "$HOME/.config/sway"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.images"

# ------------------------------------------------------------
# Install Sway config
# ------------------------------------------------------------

echo
echo "==> Installing Sway config..."

cp "$DOTFILES_DIR/config" "$HOME/.config/sway/config"

# Install Waybar
mkdir -p "$HOME/.config/waybar"
cp -r "$DOTFILES_DIR/waybar/." "$HOME/.config/waybar/"

# Install Wofi
mkdir -p "$HOME/.config/wofi"
cp -r "$DOTFILES_DIR/wofi/." "$HOME/.config/wofi/"

# Install Alacritty
mkdir -p "$HOME/.config/alacritty"
cp -r "$DOTFILES_DIR/alacritty/." "$HOME/.config/alacritty/"

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Zsh plugins
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# Install our Zsh configuration
cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# ------------------------------------------------------------
# Install scripts
# ------------------------------------------------------------

echo
echo "==> Installing scripts..."

cp "$DOTFILES_DIR/scripts/toggle-scratchpad" \
   "$HOME/.local/bin/toggle-scratchpad"

cp "$DOTFILES_DIR/scripts/asciiquarium-all" \
   "$HOME/.local/bin/asciiquarium-all"

chmod +x "$HOME/.local/bin/toggle-scratchpad"
chmod +x "$HOME/.local/bin/asciiquarium-all"

# ------------------------------------------------------------
# Install wallpaper
# ------------------------------------------------------------

echo
echo "==> Installing wallpaper..."

cp "$DOTFILES_DIR/wallpaper.jpg" \
   "$HOME/.images/wallpaper.jpg"

# ------------------------------------------------------------
# Enable services
# ------------------------------------------------------------

echo
echo "==> Enabling services..."

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

# ------------------------------------------------------------
# Zsh
# ------------------------------------------------------------

echo
echo "==> Setting Zsh as default shell..."

if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi

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
echo "  Sway"
echo "  Waybar"
echo "  Wofi"
echo "  Kitty"
echo "  Firefox"
echo "  Nautilus"
echo "  PipeWire"
echo "  Bluetooth"
echo "  NetworkManager"
echo "  Asciiquarium"
echo "  VS Code"
echo "  paru"
echo
echo "Your configuration is located at:"
echo "  ~/.config/sway/config"
echo
echo "Scripts:"
echo "  ~/.local/bin/toggle-scratchpad"
echo "  ~/.local/bin/asciiquarium-all"
echo
echo "Wallpaper:"
echo "  ~/.images/wallpaper.jpg"
echo
echo "IMPORTANT:"
echo "Your monitor configuration is specific to your hardware."
echo "Check the 'output' lines in ~/.config/sway/config"
echo "before using this setup on another computer."
echo
echo "A reboot or new Sway session is recommended."
echo

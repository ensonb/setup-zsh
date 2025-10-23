#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
    echo $OS
}

# Check if running with sudo for Linux
check_sudo() {
    if [[ "$OS" != "macos" ]]; then
        if [ "$EUID" -eq 0 ]; then
            print_error "Please don't run this script with sudo. It will ask for sudo when needed."
            exit 1
        fi
    fi
}

# Install zsh
install_zsh() {
    print_info "Installing Zsh..."
    
    case $OS in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y zsh git curl wget
            ;;
        fedora|rhel|centos)
            sudo dnf install -y zsh git curl wget
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm zsh git curl wget
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                print_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh git curl wget
            ;;
        *)
            print_error "Unsupported OS. Please install zsh manually."
            exit 1
            ;;
    esac
    
    print_success "Zsh installed successfully!"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh is already installed. Skipping..."
        return
    fi
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    print_success "Oh My Zsh installed successfully!"
}

# Install JetBrains Mono Nerd Font
install_nerd_font() {
    print_info "Installing JetBrains Mono Nerd Font..."
    
    FONT_DIR=""
    
    if [[ "$OS" == "macos" ]]; then
        FONT_DIR="$HOME/Library/Fonts"
    else
        FONT_DIR="$HOME/.local/share/fonts"
    fi
    
    mkdir -p "$FONT_DIR"
    
    # Download JetBrains Mono Nerd Font
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TMP_DIR=$(mktemp -d)
    
    print_info "Downloading JetBrains Mono Nerd Font..."
    wget -q --show-progress "$FONT_URL" -O "$TMP_DIR/JetBrainsMono.zip"
    
    print_info "Extracting font files..."
    unzip -q "$TMP_DIR/JetBrainsMono.zip" -d "$TMP_DIR/JetBrainsMono"
    
    # Copy only the regular font files (not the Windows compatible ones)
    find "$TMP_DIR/JetBrainsMono" -name "*.ttf" -exec cp {} "$FONT_DIR" \;
    
    # Update font cache on Linux
    if [[ "$OS" != "macos" ]]; then
        fc-cache -fv "$FONT_DIR"
    fi
    
    # Cleanup
    rm -rf "$TMP_DIR"
    
    print_success "JetBrains Mono Nerd Font installed successfully!"
    print_warning "Please set your terminal font to 'JetBrainsMono Nerd Font' or 'JetBrainsMono NF'"
}

# Install Powerlevel10k
install_powerlevel10k() {
    print_info "Installing Powerlevel10k..."
    
    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$P10K_DIR" ]; then
        print_warning "Powerlevel10k is already installed. Skipping..."
        return
    fi
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    
    print_success "Powerlevel10k installed successfully!"
}

# Configure .zshrc
configure_zshrc() {
    print_info "Configuring .zshrc..."
    
    ZSHRC="$HOME/.zshrc"
    
    # Backup existing .zshrc
    if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
        print_info "Backed up existing .zshrc"
    fi
    
    # Update theme in .zshrc
    if grep -q "^ZSH_THEME=" "$ZSHRC"; then
        sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
    else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
    fi
    
    # Add useful plugins if not already present
    if ! grep -q "plugins=(git" "$ZSHRC"; then
        sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
    fi
    
    print_success ".zshrc configured successfully!"
}

# Install useful Oh My Zsh plugins
install_plugins() {
    print_info "Installing useful plugins..."
    
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed!"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed!"
    fi
}

# Set zsh as default shell
set_default_shell() {
    print_info "Setting Zsh as default shell..."
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
        print_success "Zsh set as default shell!"
        print_warning "Please log out and log back in for the change to take effect."
    else
        print_info "Zsh is already the default shell."
    fi
}

# Main installation
main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║   Zsh + Oh My Zsh + Powerlevel10k Installation       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    
    OS=$(detect_os)
    print_info "Detected OS: $OS"
    
    check_sudo
    
    # Check if zsh is already installed
    if ! command -v zsh &> /dev/null; then
        install_zsh
    else
        print_info "Zsh is already installed. Version: $(zsh --version)"
    fi
    
    install_oh_my_zsh
    install_nerd_font
    install_powerlevel10k
    install_plugins
    configure_zshrc
    set_default_shell
    
    echo ""
    print_success "Installation complete! 🎉"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Set your terminal font to 'JetBrainsMono Nerd Font'"
    echo "  3. Run 'p10k configure' to customize your prompt"
    echo ""
    print_warning "If you see any strange characters, make sure your terminal is using the Nerd Font!"
    echo ""
}

# Run main function
main

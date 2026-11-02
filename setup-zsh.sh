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
    
    # Enable autosuggestions + syntax highlighting if not already enabled
    if ! grep -q "^plugins=.*zsh-autosuggestions" "$ZSHRC"; then
        sed -i.bak 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
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

# Install the saved Powerlevel10k prompt config (skips the p10k wizard)
P10K_URL="https://raw.githubusercontent.com/ensonb/setup-zsh/main/p10k.zsh"

install_p10k_config() {
    print_info "Installing Powerlevel10k prompt config..."

    ZSHRC="$HOME/.zshrc"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

    if [ -f "$HOME/.p10k.zsh" ]; then
        cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup.$(date +%Y%m%d%H%M%S)"
        print_info "Backed up existing .p10k.zsh"
    fi

    # Use the copy next to this script, or download it when run via curl | bash
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/p10k.zsh" ]; then
        cp "$SCRIPT_DIR/p10k.zsh" "$HOME/.p10k.zsh"
    elif ! curl -fsSL "$P10K_URL" -o "$HOME/.p10k.zsh"; then
        print_warning "Could not get p10k.zsh. Run 'p10k configure' to set up the prompt."
        return
    fi

    # Instant prompt block must sit at the very top of .zshrc
    if ! grep -q "p10k-instant-prompt" "$ZSHRC"; then
        TMP_RC=$(mktemp)
        cat > "$TMP_RC" << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

EOF
        cat "$ZSHRC" >> "$TMP_RC"
        mv "$TMP_RC" "$ZSHRC"
    fi

    if ! grep -q "source ~/.p10k.zsh" "$ZSHRC"; then
        cat >> "$ZSHRC" << 'EOF'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    fi

    print_success "Powerlevel10k prompt config installed!"
}

# Add personal aliases
add_aliases() {
    print_info "Adding aliases..."

    ZSHRC="$HOME/.zshrc"

    if grep -q "# setup-zsh aliases" "$ZSHRC"; then
        print_info "Aliases already present. Skipping..."
        return
    fi

    cat >> "$ZSHRC" << 'EOF'

# setup-zsh aliases
export PATH="$HOME/.local/bin:$PATH"
alias ld='ls -lhtrd */'
alias ltr='ls -lhtr'
alias www='cd /var/www/html'

# Claude / openclaw
alias clx='claude --dangerously-skip-permissions'
alias opc='cd ~/.openclaw && claude --enable-auto-mode'
alias cldr='cd ~/.openclaw && claude --resume'
EOF

    print_success "Aliases added!"
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
    install_p10k_config
    add_aliases
    set_default_shell
    
    echo ""
    print_success "Installation complete! 🎉"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Set your terminal font to 'JetBrainsMono Nerd Font'"
    echo "  3. Prompt is preconfigured; run 'p10k configure' to change it"
    echo ""
    print_warning "If you see any strange characters, make sure your terminal is using the Nerd Font!"
    echo ""
}

# Run main function
main

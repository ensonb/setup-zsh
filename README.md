# 🚀 Zsh Ultimate Setup

A comprehensive automated installation script for setting up a beautiful and productive terminal environment with Zsh, Oh My Zsh, Powerlevel10k, and JetBrains Mono Nerd Font.

![Terminal Preview](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/prompt-styles-high-contrast.png)

## ✨ Features

- **Zsh**: Modern shell with powerful features
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Beautiful and fast prompt theme
- **JetBrains Mono Nerd Font**: Patched font with icons and ligatures
- **Useful Plugins**:
  - `zsh-autosuggestions` - Fish-like autosuggestions
  - `zsh-syntax-highlighting` - Command syntax highlighting

## 🖥️ Supported Systems

- ✅ Ubuntu / Debian
- ✅ Fedora / RHEL / CentOS
- ✅ Arch Linux / Manjaro
- ✅ macOS

## 📦 What Gets Installed

1. **Zsh** - The Z shell
2. **Oh My Zsh** - Zsh configuration framework
3. **Powerlevel10k** - Supercharged prompt theme
4. **JetBrains Mono Nerd Font** - Font with programming ligatures and icons
5. **Useful plugins** - Autosuggestions and syntax highlighting
6. **Saved prompt style** - `p10k.zsh` (rainbow, Nerd Font icons) copied to `~/.p10k.zsh`, so the p10k wizard is skipped
7. **Aliases** - `ld`, `ltr`, `www`, plus Claude/openclaw shortcuts `clx`, `opc`, `cldr`

## 🚀 Quick Start

### One-Line Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ensonb/setup-zsh/main/setup-zsh.sh)
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/ensonb/setup-zsh.git
cd setup-zsh
```

2. Make the script executable:
```bash
chmod +x setup-zsh.sh
```

3. Run the installation:
```bash
./setup-zsh.sh
```

## 📝 Post-Installation Steps

1. **Restart your terminal** or source the configuration:
   ```bash
   source ~/.zshrc
   ```

2. **Configure your terminal font**:
   - Set font to: `JetBrainsMono Nerd Font` or `JetBrainsMono NF`
   - Font size: 12-14 recommended

3. **Change the prompt style** (optional; a saved style is installed by default):
   ```bash
   p10k configure
   ```

## 🎨 Terminal Font Configuration

### Common Terminals

#### iTerm2 (macOS)
1. `iTerm2` → `Preferences` → `Profiles` → `Text`
2. Set Font to: `JetBrainsMono Nerd Font`
3. Recommended size: 13

#### GNOME Terminal (Linux)
1. `Edit` → `Preferences` → `Profiles` → Select your profile
2. Check "Custom font"
3. Select: `JetBrainsMono Nerd Font Regular`

#### Windows Terminal
1. `Settings` → `Profiles` → Select your profile
2. `Appearance` → `Font face`
3. Select: `JetBrainsMono NF`

#### VS Code Integrated Terminal
Add to `settings.json`:
```json
{
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"
}
```

## ⚙️ Customization

### Change Powerlevel10k Style
```bash
p10k configure
```

### Edit Zsh Configuration
```bash
nano ~/.zshrc
```

### Add More Plugins
Edit `~/.zshrc` and add plugins to the plugins array:
```bash
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  # Add more plugins here
)
```

Popular plugins:
- `docker` - Docker completions
- `kubectl` - Kubernetes completions
- `npm` - NPM completions
- `python` - Python completions

## 🔧 Troubleshooting

### Icons Not Showing
- Make sure you're using the Nerd Font in your terminal
- Restart your terminal after changing the font

### Slow Prompt
Run the configuration wizard again:
```bash
p10k configure
```
Choose the "instant prompt" option.

### Permission Denied
Make sure the script is executable:
```bash
chmod +x setup-zsh.sh
```

### Zsh Not Default Shell
Run:
```bash
chsh -s $(which zsh)
```
Then log out and log back in.

## 🗑️ Uninstallation

To remove Oh My Zsh:
```bash
uninstall_oh_my_zsh
```

To remove the Nerd Font:
```bash
# Linux
rm -rf ~/.local/share/fonts/JetBrainsMono*
fc-cache -fv

# macOS
rm -rf ~/Library/Fonts/JetBrainsMono*
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

## 📸 Screenshots

![Screenshot 1](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/configuration-wizard.gif)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

#!/bin/bash

# =============================================================================
# Script d'installation post-install - Garuda/Arch Linux
# Utilisateur: greg
# Description: Installation automatisée des outils essentiels
# =============================================================================

set -euo pipefail  # Arrêt en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Vérifier que l'utilisateur est greg
if [ "$USER" != "greg" ]; then
    print_error "Ce script doit être exécuté par l'utilisateur 'greg'"
    exit 1
fi

# Demander le mot de passe sudo une seule fois et maintenir la session
print_header "Authentification sudo"
sudo -v
# Maintenir sudo en arrière-plan
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

print_header "Mise à jour du système"
sudo pacman -Syu --noconfirm

# Installation des paquets de base depuis les repos officiels
print_header "Installation des paquets de base"
OFFICIAL_PACKAGES=(
    "git"
    "curl"
    "wget"
    "base-devel"
    "touchegg"
    "nodejs"
    "npm"
    "python"
    "python-pip"
    "jq"
    "unzip"
    "zip"
)

for package in "${OFFICIAL_PACKAGES[@]}"; do
    if pacman -Qi "$package" &> /dev/null; then
        print_status "$package déjà installé"
    else
        print_status "Installation de $package..."
        sudo pacman -S --noconfirm "$package"
    fi
done

# Installation de yay (AUR helper) si pas installé
print_header "Vérification de yay (AUR helper)"
if ! command -v yay &> /dev/null; then
    print_status "Installation de yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
else
    print_status "yay déjà installé"
fi

# Installation kubectl
print_header "Installation de kubectl"
if ! command -v kubectl &> /dev/null; then
    print_status "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Autocomplétion pour Fish
    mkdir -p ~/.config/fish/completions
    kubectl completion fish > ~/.config/fish/completions/kubectl.fish
else
    print_status "kubectl déjà installé"
fi

# Installation SDKMAN
print_header "Installation de SDKMAN"
if [ ! -d "$HOME/.sdkman" ]; then
    print_status "Installation de SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    print_status "SDKMAN déjà installé"
fi

# Installation NVM
print_header "Installation de NVM"
if [ ! -d "$HOME/.nvm" ]; then
    print_status "Installation de NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Installation de la dernière version LTS de Node
    nvm install --lts
    nvm use --lts
else
    print_status "NVM déjà installé"
fi

# Installation HyprPanel
print_header "Installation de HyprPanel"
if [ ! -d "$HOME/.config/hyprpanel" ]; then
    print_status "Clonage de HyprPanel..."
    yay -S ags-hyprpanel-git
else
    print_status "HyprPanel déjà cloné"
fi

# Installation end-4 dots-hyprland
print_header "Installation de end-4 dots-hyprland"
if [ ! -d "$HOME/dots-hyprland" ]; then
    print_status "Clonage de end-4 dots-hyprland..."
    cd ~
    git clone https://github.com/end-4/dots-hyprland.git
    cd dots-hyprland

    print_status "Exécution de l'installeur end-4..."
    # Note: L'installeur end-4 demande parfois sudo, le maintien en arrière-plan devrait aider
    ./install.sh
else
    print_status "dots-hyprland déjà cloné"
fi

# Configuration touchegg
print_header "Configuration de touchegg"
mkdir -p ~/.config/touchegg
if [ ! -f ~/.config/touchegg/touchegg.conf ]; then
    print_status "Création de la config touchegg..."
    cat > ~/.config/touchegg/touchegg.conf << 'EOF'
<touchégg>
  <settings>
    <property name="animation_delay">150</property>
  </settings>
  <application name="All">
    <gesture type="PINCH" fingers="2" direction="IN">
      <action type="RUN_COMMAND">
        <command>hyprctl dispatch splitratio -0.1</command>
      </action>
    </gesture>
    <gesture type="PINCH" fingers="2" direction="OUT">
      <action type="RUN_COMMAND">
        <command>hyprctl dispatch splitratio 0.1</command>
      </action>
    </gesture>
  </application>
</touchégg>
EOF
else
    print_status "Configuration touchegg déjà présente"
fi

# Activation des services
print_header "Activation des services"
systemctl --user enable touchegg || print_warning "Impossible d'activer touchegg (peut nécessiter une session graphique)"

# Configuration Fish (si Fish est le shell par défaut)
print_header "Configuration Fish"
if [ "$SHELL" = "/usr/bin/fish" ]; then
    print_status "Configuration de Fish Shell..."

    # Créer le fichier de config Fish avec les variables d'environnement
    mkdir -p ~/.config/fish
    cat >> ~/.config/fish/config.fish << 'EOF'

# Variables d'environnement pour le développement
set -gx SDKMAN_DIR "$HOME/.sdkman"
set -gx NVM_DIR "$HOME/.nvm"

# Initialisation SDKMAN pour Fish
if test -s "$SDKMAN_DIR/bin/sdkman-init.sh"
    bass source "$SDKMAN_DIR/bin/sdkman-init.sh"
end

# Alias utiles
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

EOF

    # Installer bass pour Fish (pour sourcer des scripts bash)
    if ! functions -q bass
        print_status "Installation de bass pour Fish..."
        curl -L https://get.oh-my.fish | fish
        omf install bass
    fi
fi

# Message de fin
print_header "Installation terminée !"
echo -e "${GREEN}✅ Tous les outils ont été installés avec succès !${NC}\n"

echo "Outils installés :"
echo "  • touchegg (gestures)"
echo "  • kubectl (Kubernetes)"
echo "  • SDKMAN (Java/Kotlin/Scala)"
echo "  • NVM (Node.js)"
echo "  • HyprPanel (interface Hyprland)"
echo "  • end-4 dots-hyprland (configuration)"

echo -e "\n${YELLOW}Actions recommandées :${NC}"
echo "  1. Redémarrer votre session"
echo "  2. Configurer chezmoi pour restaurer vos dotfiles"
echo "  3. Lancer HyprPanel depuis ~/HyprPanel"
echo "  4. Activer touchegg avec: systemctl --user start touchegg"

echo -e "\n${BLUE}Pour NVM et SDKMAN :${NC}"
echo "  • Redémarrer votre terminal ou sourcer les configs"
echo "  • NVM: nvm install node && nvm use node"
echo "  • SDKMAN: sdk install java"

print_status "Script d'installation terminé !"


print_status "Libinput gesture now !"

#gesture pinch clockwise hyprctl dispatch splitratio 0.1
#gesture pinch anticlockwise hyprctl dispatch splitratio -0.1

#libinput-gestures-setup start
#fisher install jethrokuan/z

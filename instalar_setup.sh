#!/bin/bash

cat << "EOF"
.___                 __         .__  .__          __  .__               
|   | ____   _______/  |______  |  | |  | _____ _/  |_|__| ____   ____  
|   |/    \ /  ___/\   __\__  \ |  | |  | \__  \\   __\  |/  _ \ /    \ 
|   |   |  \\___ \  |  |  / __ \|  |_|  |__/ __ \|  | |  (  <_> )   |  \
|___|___|  /____  > |__| (____  /____/____(____  /__| |__|\____/|___|  /
         \/     \/            \/               \/                    \/ 
     _________            .__        __                                 
    /   _____/ ___________|__|______/  |_                               
    \_____  \_/ ___\_  __ \  \____ \   __\                              
    /        \  \___|  | \/  |  |_> >  |                                
   /_______  /\___  >__|  |__|   __/|__|                                
           \/     \/         |__|                                       
                                                         
                             --- by MAKO ---
EOF
echo ""
sleep 1 

# ==========================================
# FASE 1: DEBLOAT & PRE-INSTALLATION
# ==========================================
cat << "EOF"
  _____       _     _             _   
 |  __ \     | |   | |           | |  
 | |  | | ___| |__ | | ___   __ _| |_ 
 | |  | |/ _ \ '_ \| |/ _ \ / _` | __|
 | |__| |  __/ |_) | | (_) | (_| | |_ 
 |_____/ \___|_.__/|_|\___/ \__,_|\__|                                  
EOF
echo ""

# Limpiando el sistema
sudo dnf upgrade --refresh -y
# Fulminando aplicaciones de GNOME innecesarias
sudo dnf remove -y gnome-contacts gnome-weather gnome-clocks gnome-maps simple-scan mediawriter gnome-boxes libreoffice* gnome-characters gnome-tour yelp gnome-connections gnome-font-viewer gnome-calendar firefox
# Pasando la escoba
sudo dnf autoremove -y
# Fase de limpieza completada.

# ==========================================
# FASE 2: CONFIGURATION & INSTALLATION
# ==========================================
cat << "EOF"
  _____             __ _                       _   _             
 / ____|           / _(_)                     | | (_)        
| |     ___  _ __ | |_ _  __ _ _   _ _ __ __ _| |_ _  ___  _ __  
| |    / _ \| '_ \|  _| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \ 
| |___| (_) | | | | | | | (_| | |_| | | | (_| | |_| | (_) | | | |
 \_____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
                          __/ |                                  
                         |___/          
EOF
echo ""  

echo "📦 Activando repositorios de terceros..."
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y kazeev/kew
sudo dnf copr enable -y imput/helium

echo "🔐 Añadiendo repositorios para software comercial..."
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm

echo "🔄 Refrescando la base de datos de paquetes..."
sudo dnf makecache

echo "🚀 Descargando e instalando paquetería nativa con DNF..."

# Matriz de aplicaciones DNF (sin Obsidian)
APPS=(
    kitty
    neovim
    yazi
    eza
    btop
    fastfetch
    cava
    kew
    cool-retro-term
    gimp
    discord
    onlyoffice-desktopeditors
    helium-bin
    starship
)

sudo dnf install -y --skip-unavailable "${APPS[@]}"

echo "🔍 Realizando auditoría de instalación DNF..."
FALTAN=0
echo "----------------------------------------"
for app in "${APPS[@]}"; do
    if ! rpm -q "$app" &>/dev/null; then
        echo "❌ No se pudo instalar: $app"
        FALTAN=$((FALTAN + 1))
    fi
done
echo "----------------------------------------"

if [ $FALTAN -gt 0 ]; then
    echo "⚠️  Atención: Faltaron $FALTAN paquetes nativos."
else
    echo "✅ Todas las aplicaciones nativas se instalaron correctamente."
fi

echo "⚡ Instalando editores de nueva generación (ZED)..."
curl -f https://zed.dev/install.sh | sh

echo "📦 Instalando aplicaciones contenidas (Flatpak)..."
# Conectamos con Flathub por si acaso no estaba activado
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# Instalamos Obsidian en formato Flatpak de forma desatendida
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.valvesoftware.Steam

echo "✅ Aprovisionamiento completado."

# ==========================================
# FASE 3: POST-INSTALL & DOTFILES
# ==========================================
cat << "EOF"
  _____          _        _____           _        _ _       _   _             
 |  __ \        | |      |_   _|         | |      | | |     | | | |            
 | |__) |__  ___| |_ ______| |  _ __  ___| |_ __ _| | | __ _| |_| | ___  _ __  
 |  ___/ _ \/ __| __|______| | | '_ \/ __| __/ _` | | |/ _` | __| |/ _ \| '_ \ 
 | |  | (_) \__ \ |_      _| |_| | | \__ \ || (_| | | | (_| | |_| | (_) | | | |
 |_|   \___/|___/\__|    |_____|_| |_|___/\__\__,_|_|_|\__,_|\__|_|\___/|_| |_|
EOF
echo ""

echo "📂 Preparando el terreno para tus configuraciones..."
mkdir -p ~/.config

echo "✨ Inyectando tu ADN en el sistema (Copiando Dotfiles)..."
cp -r dotfiles/nvim ~/.config/ 2>/dev/null
cp -r dotfiles/kitty ~/.config/ 2>/dev/null
cp -r dotfiles/yazi ~/.config/ 2>/dev/null
cp -r dotfiles/btop ~/.config/ 2>/dev/null
cp -r dotfiles/fastfetch ~/.config/ 2>/dev/null
cp -r dotfiles/kew ~/.config/ 2>/dev/null
cp dotfiles/starship.toml ~/.config/ 2>/dev/null
cp dotfiles/.bashrc ~/ 2>/dev/null

echo "🔐 Ajustando permisos..."
chmod -R +x ~/.config/nvim/ 2>/dev/null

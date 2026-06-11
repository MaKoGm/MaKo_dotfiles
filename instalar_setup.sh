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
sudo dnf copr enable -y atim/starship

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

# ==========================================
# FASE 4: GNOME CUSTOMIZATION
# ==========================================
cat << "EOF"
   _____ _   _  ____  __  __ ______ 
  / ____| \ | |/ __ \|  \/  |  ____|
 | |  __|  \| | |  | | \  / | |__   
 | | |_ | . ` | |  | | |\/| |  __|  
 | |__| | |\  | |__| | |  | | |____ 
  \_____|_| \_|\____/|_|  |_|______|
EOF
echo ""

echo "🎨 Configurando PANTALLA y APARIENCIA..."
# Activar el Modo Oscuro
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# Recordatorio: La resolución, los 144Hz y la escala (1.25) se aplican automáticamente 
# si copias tu archivo ~/.config/monitors.xml en tu carpeta dotfiles.

echo "🔋 Configurando BATERÍA..."
# Mostrar el porcentaje numérico en la barra
gsettings set org.gnome.desktop.interface show-battery-percentage true

echo "🔄 Configurando MULTITAREA..."
# Mostrar solo aplicaciones del escritorio actual en el menú (Alt+Tab)
gsettings set org.gnome.shell.app-switcher current-workspace-only true
# Desactivar la Esquina Activa superior izquierda (hot-corner)
gsettings set org.gnome.desktop.interface enable-hot-corners false

echo "🖱️ Configurando RATÓN y TOUCHPAD..."
# Desactivar la aceleración del ratón (Perfil 'flat')
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

echo "⚙️ Configurando TECLADO y BLOQ MAYÚS..."
# Convertir Bloq Mayús en Escape (Shift + Bloq Mayús será el Bloq Mayús normal)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape_shifted_capslock']"

echo "🖥️ Configurando ESPACIOS DE TRABAJO (Estilo Tiling)..."
# Desactivar la creación dinámica y forzar 9 escritorios fijos
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3

echo "⌨️ Configurando ATAJOS DE TECLADO..."
# --- 1. Atajos integrados ---
# Cerrar ventana con Super + C (Sustituye al Alt+F4)
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"

# Mapear navegación de escritorios 
for i in {1..3}; do
    # Super + X = Ir al escritorio X
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    # Super + Shift + X = Mover ventana actual al escritorio X
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done

# --- 2. Atajos de aplicaciones personalizadas ---
# Definir los tres espacios (rutas) para nuestras aplicaciones
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"

# Atajo 1: Terminal Kitty (Super + Q)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>q'

# Atajo 2: Navegador Helium (Super + B)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Helium'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'helium'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>b'

# Atajo 3: Discord Flatpak (Super + D)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Discord'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'flatpak run com.discordapp.Discord'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>d'

echo ""
echo "=================================================================="
echo "🎉 ¡MAGIA COMPLETADA! GNOME está configurado al estilo Hyprland."
echo "⚠️  Por favor, reinicia la sesión para aplicar los cambios de teclado."
echo "=================================================================="

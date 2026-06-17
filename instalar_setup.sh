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

echo "Activando repositorios de terceros..."
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y kazeev/kew
sudo dnf copr enable -y imput/helium
sudo dnf copr enable -y atim/starship

echo "Añadiendo repositorios para software comercial..."
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm

echo "Refrescando la base de datos de paquetes..."
sudo dnf makecache

# Matriz de aplicaciones DNF
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
    gnome-tweaks
    pipx
)

sudo dnf install -y --skip-unavailable "${APPS[@]}"

echo "Realizando auditoría de instalación DNF..."
FALTAN=0
echo "----------------------------------------"
for app in "${APPS[@]}"; do
    if ! rpm -q "$app" &>/dev/null; then
        echo "No se pudo instalar: $app"
        FALTAN=$((FALTAN + 1))
    fi
done
echo "----------------------------------------"

if [ $FALTAN -gt 0 ]; then
    echo "Atención: Faltaron $FALTAN paquetes nativos."
else
    echo "Todas las aplicaciones nativas se instalaron correctamente."
fi

echo "Instalando herramientas Python por pipx"
pipx install git+https://github.com/ZXCurban/NetOrbit.git
pipx install gnome-extensions-cli --force

echo "Instalando aplicaciones (Flatpak)..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub dev.zed.Zed
flatpak install -y flathub com.mattjakeman.ExtensionManager

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

# nos aseguramos que la carpeta existe
mkdir -p ~/.config

echo "Copiando Dotfiles..."
cp -r dotfiles/nvim ~/.config/ 2>/dev/null
cp -r dotfiles/kitty ~/.config/ 2>/dev/null
cp -r dotfiles/yazi ~/.config/ 2>/dev/null
cp -r dotfiles/btop ~/.config/ 2>/dev/null
cp -r dotfiles/fastfetch ~/.config/ 2>/dev/null
cp -r dotfiles/kew ~/.config/ 2>/dev/null
cp dotfiles/starship.toml ~/.config/ 2>/dev/null
cp dotfiles/.bashrc ~/ 2>/dev/null

### **no tengo del todo claro que esto sea necesario lo tenog que mirar más en detalle**
echo "Ajustando permisos..."
chmod -R +x ~/.config/nvim/ 2>/dev/null

echo "Instalando tipografía: JetBrains Mono Nerd Font..."

# 1. Aseguramos que tenemos las herramientas necesarias
sudo dnf install -y unzip curl
# 2. Creamos la carpeta local de fuentes del usuario 
mkdir -p ~/.local/share/fonts/JetBrainsMono
# 3. Descargamos la última versión del repositorio oficial de Nerd Fonts a la carpeta temporal
curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
# 4. Extraemos el contenido
unzip -q -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono
# 5. Borramos el archivo ZIP temporal para dejar todo limpio
rm /tmp/JetBrainsMono.zip
# 6. Actualizamos la caché de fuentes para que el sistema reconozca la tipografía al instante
fc-cache -f -v ~/.local/share/fonts/JetBrainsMono > /dev/null

echo "Configurando JetBrains Mono como fuente GLOBAL del sistema..."
# 1. Fuente de la interfaz general (menús, barra superior, carpetas)
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 11'
# 2. Fuente para la visualización de documentos
gsettings set org.gnome.desktop.interface document-font-name 'JetBrainsMono Nerd Font 11'
# 3. Fuente de las barras de título de las ventanas (usamos Bold para que resalte un poco)
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'JetBrainsMono Nerd Font Bold 11'
# 4. Fuente monoespaciada (para la terminal y editores de código)
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
echo "¡Fuente instalada correctamente!"

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

echo "Configurando el FONDO DE PANTALLA..."
# 1. Crear la carpeta estándar
mkdir -p ~/.local/share/backgrounds
# 2. Copiar la imagen desde tus dotfiles (se aplica la que tenga el nombre mi_fondo.jpg)
if [ -f "dotfiles/wallpapers/mi_fondo.jpg" ]; then
    cp dotfiles/wallpapers/mi_fondo.jpg ~/.local/share/backgrounds/
    WALLPAPER_URI="file://$HOME/.local/share/backgrounds/mi_fondo.jpg"
    gsettings set org.gnome.desktop.background picture-uri "$WALLPAPER_URI"
    gsettings set org.gnome.desktop.background picture-uri-dark "$WALLPAPER_URI"
    echo "Fondo de pantalla aplicado correctamente."
else
    echo "Aviso: No se encontró la imagen en dotfiles/wallpapers/mi_fondo.jpg"
fi


echo "Configurando PANTALLA y APARIENCIA..."
# Activar el Modo Oscuro
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
# Copiar configuración de monitores (resolución, Hz, escala) si existe
if [ -f "dotfiles/monitors.xml" ]; then
    echo "Aplicando configuración de monitores desde dotfiles..."
    cp dotfiles/monitors.xml ~/.config/
else
    echo "Aviso: No se encontró dotfiles/monitors.xml, omite la configuración de pantallas."
fi

echo "Configurando BATERÍA..."
# Mostrar el porcentaje numérico en la barra
gsettings set org.gnome.desktop.interface show-battery-percentage true
# Asegurar que el gestor moderno de energía (Tuned) esté activo
sudo systemctl enable --now tuned

echo "Configurando MULTITAREA..."
# Mostrar solo aplicaciones del escritorio actual en el menú (Alt+Tab)
gsettings set org.gnome.shell.app-switcher current-workspace-only true
# Desactivar la Esquina Activa superior izquierda (hot-corner)
gsettings set org.gnome.desktop.interface enable-hot-corners false

echo "Configurando RATÓN y TOUCHPAD..."
# Desactivar la aceleración del ratón (Perfil 'flat')
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

echo "Configurando TECLADO y BLOQ MAYÚS..."
# Convertir Bloq Mayús en Escape (Shift + Bloq Mayús será el Bloq Mayús normal)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape_shifted_capslock']"

echo "Configurando ESPACIOS DE TRABAJO"
# Desactivar la creación dinámica y forzar 3 escritorios fijos
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 3

# ---------------------------------------------------------

echo "Configurando atajos de sistema y ventanas..."
# Nautilus (Explorador de archivos) con Super + E
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
# Cerrar ventana con Super + C (Sustituye al Alt+F4)
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>c']"
echo "Liberando atajos bloqueados por GNOME Shell..."
# GNOME usa Super+1..9 para abrir apps del dock. Vaciamos esa configuración primero.
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done
echo "Asignando navegación de escritorios virtuales..."
# Moverse a los escritorios virtuales y mover ventanas (Super + 1, 2, 3)
for i in {1..3}; do
    # Ir al escritorio X
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    # Mover ventana actual al escritorio X
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
# Función para añadir atajos personalizados de forma segura sin borrar los existentes
add_custom_shortcut() {
    local name=$1
    local command=$2
    local binding=$3
    
    # Generar un ID único para evitar colisiones
    local id="custom_$(date +%s%N)_$RANDOM" 
    local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${id}/"

    # Obtener la lista actual de atajos personalizados
    local current_list=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
    
    # Preparar la nueva lista
    if [ "$current_list" = "@as []" ]; then
        # Si la lista está vacía
        local new_list="['$path']"
    else
        # Si ya hay atajos, quitamos el corchete final, añadimos coma y la nueva ruta
        local new_list="${current_list%]*}, '$path']"
    fi
    # Guardar la nueva lista de rutas
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_list"
    # Configurar las propiedades del nuevo atajo
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path binding "$binding"
    echo "Añadido atajo: $name ($binding)"
}

echo "Configurando atajos personalizados..."
# Atajo 1: Terminal Kitty (Super + Q)
add_custom_shortcut "Terminal Kitty" "kitty" "<Super>q"
# Atajo 2: Navegador Helium (Super + B)
add_custom_shortcut "Navegador Helium" "helium" "<Super>b"
# Atajo 3: Discord Flatpak (Super + D)
add_custom_shortcut "Discord Flatpak" "flatpak run com.discordapp.Discord" "<Super>d"
echo "¡Todos los atajos han sido configurados con éxito!"


echo "Configurando EXTENSIONES DE GNOME"
echo "Descargando y activando extensiones clave..."
# Usamos la ruta absoluta de gext para evitar fallos del PATH
GEXT_CMD="$HOME/.local/bin/gext"
# 1. Auto Power Profile
$GEXT_CMD install auto-power-profile@dmy3k.github.io 1>/dev/null
$GEXT_CMD enable auto-power-profile@dmy3k.github.io 1>/dev/null
# 2. Gnome 4x, 5x UI Improvements
$GEXT_CMD install gnome-ui-tune@itstime.tech 1>/dev/null
$GEXT_CMD enable gnome-ui-tune@itstime.tech 1>/dev/null
# 3. User Themes (Obligatoria para tu tema Colloid)
$GEXT_CMD install user-theme@gnome-shell-extensions.gcampax.github.com 1>/dev/null

# 1. Instalar dependencias necesarias para compilar el tema
sudo dnf install -y git sassc glib2-devel
# 2. Clonar el repositorio en la carpeta temporal /tmp
git clone https://github.com/vinceliuice/Colloid-gtk-theme.git /tmp/Colloid-gtk-theme
# 3. Ejecutar el instalador con todas tus preferencias
#   -c dark: Genera solo la versión oscura
#   -t default: Usa el color base por defecto, que al combinarlo con gruvbox da el tono ideal
#   --tweaks gruvbox rimless normal: Aplica paleta cálida, sin bordes y botones de GNOME
echo "Compilando y aplicando Colloid..."
/tmp/Colloid-gtk-theme/install.sh -c dark -t default --tweaks gruvbox rimless normal black
# 4. Parche para GNOME Moderno (Libadwaita)
# Le pasamos los mismos parámetros para que las apps nuevas (como Nautilus) hereden el diseño
/tmp/Colloid-gtk-theme/install.sh -c dark -t default --tweaks gruvbox rimless normal --libadwaita
# 5. Limpiar la carpeta temporal
rm -rf /tmp/Colloid-gtk-theme
# 6. Aplicar el tema al sistema
echo "Aplicando el tema a GNOME..."
# Aseguramos que el interruptor maestro de extensiones de GNOME esté encendido
gsettings set org.gnome.shell disable-user-extensions false
# Nos aseguramos de que la extensión User Themes está habilitada activamente
$GEXT_CMD enable user-theme@gnome-shell-extensions.gcampax.github.com 1>/dev/null
# Aplicamos el tema con el nombre EXACTO generado por el instalador
gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Dark-Gruvbox'
gsettings set org.gnome.desktop.wm.preferences theme 'Colloid-Dark-Gruvbox'
# Forzar a GNOME a leer el esquema de la extensión recién instalada
SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/schemas"
if [ -d "$SCHEMA_DIR" ]; then
    echo "Compilando esquema de User Themes..."
    glib-compile-schemas "$SCHEMA_DIR"
    gsettings --schemadir "$SCHEMA_DIR" set org.gnome.shell.extensions.user-theme name 'Colloid-Dark-Gruvbox'
else
    echo "Aviso: No se pudo aplicar el tema a la barra superior en este momento."
    echo "Tendrás que activarlo en la app 'Extensiones' después de reiniciar."
fi

###**tengo que mirar lo de instalar el tema con otro colores de carpeta y los estilos de botones de mac :D**
echo "Instalando Iconos y Cursores (Método Limpio y Estándar)..."
# 1. Crear la carpeta estándar de usuario para iconos y cursores
mkdir -p ~/.local/share/icons
# 2. Descargar y extraer Phinger Cursors directamente en la carpeta de usuario
echo "Instalando Phinger Cursors..."
curl -sL https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 | tar xfj - -C ~/.local/share/icons/
# 3. Instalar y ajustar Papirus
echo "Instalando Papirus y aplicando color Gruvbox (brown)..."
sudo dnf install -y papirus-icon-theme
curl -sL https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/install.sh | sh 1>/dev/null
papirus-folders -C brown --theme Papirus-Dark 1>/dev/null
### ***la verdad es que me he cansado con lo del raton y vamos a confiugrarlo a mano puesto que paso de intentar automatizarlo ;D***
# 4. Aplicar la configuración al sistema GNOME
echo "Aplicando temas..."
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'phinger-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24

echo ""
echo "=================================================================="
echo "¡MAGIA COMPLETADA! GNOME está configurado al estilo Hyprland."
echo "Por favor, reinicia la sesión para aplicar los cambios de teclado."
echo "=================================================================="

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
sleep 3

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

# Activando repositorios de terceros para DNF
sudo dnf copr enable -y lihaohong/yazi
sudo dnf copr enable -y kazeev/kew
sudo dnf copr enable -y alxhr0/Obsidian
sudo dnf copr enable -y imput/helium

# Añadiendo el repositorio oficial de ONLYOFFICE
sudo dnf install -y https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm

# Descargando e instalando toda la paquetería nativa
sudo dnf install -y \
    kitty \
    neovim \
    yazi \
    eza \
    btop \
    fastfetch \
    cava \
    kew \
    cool-retro-term \
    gimp \
    discord \
    obsidian \
    onlyoffice-desktopeditors \
    helium-bin

# ZED se instala por su script oficial para asegurar máxima compatibilidad
curl -f https://zed.dev/install.sh | sh
# Instalación de los programas ralizada

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

# Nos aseguramos de que la carpeta oculta .config exista en tu home. 
mkdir -p ~/.config

# Copiamos las carpetas completas
cp -r dotfiles/nvim ~/.config/
cp -r dotfiles/kitty ~/.config/
cp -r dotfiles/btop ~/.config/
cp -r dotfiles/fastfetch ~/.config/
cp -r dotfiles/kew ~/.config/

# Copiamos los archivos sueltos
cp dotfiles/starship.toml ~/.config/

# El .bashrc va directamente a tu carpeta de usuario (~/), no dentro de .config
cp dotfiles/.bashrc ~/

# Nos aseguramos de que los scripts internos que pueda tener tu Neovim se puedan ejecutar
chmod -R +x ~/.config/nvim/

echo ""
echo "=================================================================="
echo "🎉 ¡BINGO! Instalación y configuración completadas con éxito."
echo "⚠️  Por favor, reinicia el equipo para que todos los cambios se apliquen."
echo "=================================================================="                                                                                   


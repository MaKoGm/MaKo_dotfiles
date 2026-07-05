#!/bin/bash

# Definimos las rutas de destino en la máquina del usuario
DEST_FASTFETCH="$HOME/.config/fastfetch"
DEST_FF_ANIMATED="$HOME/Scripts/fastfetch"

# 1. Crear las carpetas de destino si no existen
mkdir -p "$DEST_FASTFETCH"
mkdir -p "$DEST_FF_ANIMATED"

# 2. Copiar los archivos desde tu repositorio a sus ubicaciones finales
cp -r ./dotfiles/fastfetch/* "$DEST_FASTFETCH/"
cp -r ./programs/fastfetch/* "$DEST_FF_ANIMATED/"

# 3. Compilar las animaciones en C directamente en la máquina destino
echo "⚙️ Compilando animaciones en C..."
gcc -o "$DEST_FF_ANIMATED/raindrops" "$DEST_FF_ANIMATED/raindrops.c" -lm
gcc -o "$DEST_FF_ANIMATED/radiowaves" "$DEST_FF_ANIMATED/radiowaves.c" -lm
gcc -o "$DEST_FF_ANIMATED/donut" "$DEST_FF_ANIMATED/donut.c" -lm

# 4. Dar permisos de ejecución al script maestro en bash
chmod +x "$DEST_FF_ANIMATED/start_panel.sh"

# 5. Crear el enlace simbólico global (forzamos con -f por si ya existe)
sudo ln -sf "$DEST_FF_ANIMATED/start_panel.sh" /usr/local/bin/ff_animated

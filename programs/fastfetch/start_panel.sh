#!/bin/bash

DIRECTORIO_BASE=$(dirname "$(realpath "$0")")

# ==========================================
# PREPARACIÓN Y CÁLCULOS DE PANTALLA...
# ==========================================
# PREPARACIÓN Y CÁLCULOS DE PANTALLA
# ==========================================
tput civis
trap 'tput cvvis; kill $(jobs -p) 2>/dev/null; rm -f /tmp/box_*.txt; echo -e "\e[0m"; clear; exit' SIGINT
clear

COLS=$(tput cols)
LINES=$(tput lines) # Leemos la altura total de la pantalla

# ==========================================
# 1. PARÁMETROS DE DISEÑO Y RESTRICCIONES
# ==========================================
BOX_WIDTH=51
TOTAL_BOXES_WIDTH=151
BOX_HEIGHT=9
MARGIN_BOTTOM=1

# Definimos la altura mínima para que la animación tenga espacio para respirar
MIN_LINES=45 

# CONTROL TIPO "BTOP": Si la terminal es muy pequeña, no generamos nada y avisamos
if [ "$COLS" -lt "$TOTAL_BOXES_WIDTH" ] || [ "$LINES" -lt "$MIN_LINES" ]; then
    tput cvvis
    clear
    
    # Mensaje de error de dimensiones
    MSG="Terminal demasiado pequeña. Requerido: ${TOTAL_BOXES_WIDTH}x${MIN_LINES} | Actual: ${COLS}x${LINES}"
    
    # Centramos el texto de error en la pantalla
    PAD_MSG=$(( (COLS - ${#MSG}) / 2 ))
    [ $PAD_MSG -lt 0 ] && PAD_MSG=0
    SPACE_MSG=$(printf "%${PAD_MSG}s" "")
    
    printf "\n\n\e[31m%s%s\e[0m\n\n" "$SPACE_MSG" "$MSG"
    exit 1
fi

# ==========================================
# 2. PARTE INFERIOR: Cajas ancladas al fondo (Solo Horizontal)
# ==========================================
Y_BOXES=$(( LINES - BOX_HEIGHT - MARGIN_BOTTOM ))
printf "\033[%d;1H" "$Y_BOXES"

REMAINING_SPACE=$((COLS - TOTAL_BOXES_WIDTH))
GAP_SIZE=$((REMAINING_SPACE / 4))

X1=$((GAP_SIZE + 1))
X2=$((X1 + BOX_WIDTH + GAP_SIZE))
X3=$((X2 + BOX_WIDTH + GAP_SIZE))

fastfetch -c ~/.config/fastfetch/box_os.jsonc > /tmp/box_os.txt
fastfetch -c ~/.config/fastfetch/box_ui.jsonc > /tmp/box_ui.txt
fastfetch -c ~/.config/fastfetch/box_hw.jsonc > /tmp/box_hw.txt

paste /tmp/box_os.txt /tmp/box_ui.txt /tmp/box_hw.txt | \
awk -F'\t' -v col1="\033[${X1}G" -v col2="\033[${X2}G" -v col3="\033[${X3}G" \
'{
    printf "%s%s%s%s%s%s\n", col1, $1, col2, $2, col3, $3
}'

rm -f /tmp/box_os.txt /tmp/box_ui.txt /tmp/box_hw.txt

# ==========================================
# 3. PARTE CENTRAL: Animaciones dinámicas
# ==========================================
# ==========================================
# 3. PARTE CENTRAL: Animaciones dinámicas con Máscara
# ==========================================
ANIMACION="$1"

# Si no se introduce ningún argumento, elegimos uno al azar
if [ -z "$ANIMACION" ]; then
    OPCIONES=("donut" "lluvia" "ondas")
    # Generamos un número aleatorio entre 0 y 2
    INDICE_ALEATORIO=$(( RANDOM % 3 ))
    ANIMACION="${OPCIONES[$INDICE_ALEATORIO]}"
fi
# Pasamos las coordenadas exactas a las animaciones para crear los "recintos" protegidos
# Argumentos: 1:Alto 2:Ancho 3:Y_Cajas 4:Alto_Caja 5:X1 6:X2 7:X3 8:Ancho_Caja
ARGS="$LINES $COLS $Y_BOXES 6 $X1 $X2 $X3 $BOX_WIDTH"

case "$ANIMACION" in
    "ondas")
        "$DIRECTORIO_BASE/radiowaves" $ARGS
        ;;
    "lluvia")
        "$DIRECTORIO_BASE/raindrops" $ARGS
        ;;
    "donut")
        "$DIRECTORIO_BASE/donut" 0
        ;;
    *)
       echo -e "\e[31mAnimación no reconocida. Usando donut...\e[0m"
       sleep 1
       "$DIRECTORIO_BASE/donut" 0    
       ;;
esac

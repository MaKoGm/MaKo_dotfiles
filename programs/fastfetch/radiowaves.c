#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <time.h>

// ==========================================
// MÁSCARA Y DIMENSIONES
// ==========================================
int TERM_LINES, TERM_COLS, BOX_Y, BOX_H, X1, X2, X3, BOX_W;

bool es_zona_prohibida(int fila, int columna) {
    if (fila >= BOX_Y && fila <= BOX_Y + BOX_H) {
        if (columna >= X1 && columna < X1 + BOX_W) return true;
        if (columna >= X2 && columna < X2 + BOX_W) return true;
        if (columna >= X3 && columna < X3 + BOX_W) return true;
    }
    return false;
}

// ==========================================
// PARÁMETROS DE LA ONDA (Según tu captura)
// ==========================================
#define FPS 15
#define WAVE_SPEED 0.45       // Equivalente visual al "1.00x"
#define WAVELENGTH 10.0      // Wavelength: 10
#define THICKNESS 0.18       // Thickness: 0.18 (anillos finos)
#define DECAY 1.10           // Decay: 1.10 (atenuación hacia los bordes)
#define NOISE 0.1           // Noise: 0.10 (estática analógica)

// Paleta de caracteres clásica ("Chars: classic")
const char CHARSET[] = " .:-=+*#%@"; 
const int CHARSET_LEN = 9;

int main(int argc, char *argv[]) {
    if (argc >= 9) {
        TERM_LINES = atoi(argv[1]);
        TERM_COLS  = atoi(argv[2]);
        BOX_Y      = atoi(argv[3]);
        BOX_H      = atoi(argv[4]);
        X1         = atoi(argv[5]);
        X2         = atoi(argv[6]);
        X3         = atoi(argv[7]);
        BOX_W      = atoi(argv[8]);
    } else {
        printf("Error: Faltan argumentos de máscara.\n");
        return 1;
    }

    srand(time(NULL)); // Semilla para el ruido (Noise)

    char *frame_output = malloc(TERM_LINES * TERM_COLS * 15);
    float time_var = 0.0;

    for(;;) {
        // Centro estático ("Center motion: fixed")
        float cx = TERM_COLS / 2.0;
        float cy = TERM_LINES / 2.0;

        int out_idx = 0;

        for(int r = 1; r <= TERM_LINES; r++) {
            bool cursor_needs_jump = true;
            for(int c = 1; c <= TERM_COLS; c++) {
                
                if (es_zona_prohibida(r, c)) {
                    cursor_needs_jump = true;
                    continue;
                }

                if (cursor_needs_jump) {
                    out_idx += sprintf(frame_output + out_idx, "\033[%d;%dH", r, c);
                    cursor_needs_jump = false;
                }

                float dx = (float)c - cx;
                float dy = ((float)r - cy) * 2.0; // Corrección 2:1 de la terminal
                float dist = sqrt(dx*dx + dy*dy);

                float phase = (dist / WAVELENGTH) - (time_var * WAVE_SPEED);
                float wave = (sin(phase) + 1.0) / 2.0; 

                float intensity = 0.0;

                // Aplicar grosor (Thickness)
                if (wave > 1.0 - THICKNESS) {
                    intensity = (wave - (1.0 - THICKNESS)) / THICKNESS;
                }

                // Aplicar atenuación (Decay). Lo escalamos por 0.01 para adaptarlo a la distancia en píxeles.
                intensity -= (dist * (DECAY * 0.01));

                // Añadir estática (Noise)
                if (NOISE > 0.0 && intensity > 0.0) {
                    // Genera un valor aleatorio entre -NOISE y +NOISE
                    float noise_val = (((float)rand() / RAND_MAX) * NOISE * 2.0) - NOISE;
                    intensity += noise_val;
                }

                // Limitar la intensidad a los márgenes seguros (0.0 a 1.0)
                if (intensity < 0.0) intensity = 0.0;
                if (intensity > 1.0) intensity = 1.0;
                
                // Asignar el carácter final
                int char_idx = (int)(intensity * CHARSET_LEN);
                frame_output[out_idx++] = CHARSET[char_idx];
            }
        }
        frame_output[out_idx] = '\0';

        printf("%s", frame_output);
        fflush(stdout);

        time_var += 1.0;
        
        usleep(1000000 / FPS);
    }

    free(frame_output);
    return 0;
}

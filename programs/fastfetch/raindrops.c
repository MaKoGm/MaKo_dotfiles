#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <math.h>
#include <time.h>
#include <string.h>

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
// PARÁMETROS DE LA FÍSICA (Basados en tu imagen)
// ==========================================
#define MAX_RIPPLES 50       // Límite de ondas simultáneas
#define DROP_RATE 2.5        // Gotas por segundo
#define RIPPLE_SPEED 1.2     // Velocidad a la que se expande el radio
#define RING_WIDTH 1.5       // Grosor del anillo de la onda
#define FADE_RATE 0.035      // Tasa de disolución (mientras mayor sea, antes desaparece)
#define FPS 15

// Paleta de caracteres (de menor a mayor intensidad)
const char CHARSET[] = " .:-=+*#%@"; 
const int CHARSET_LEN = 9; // Índice máximo válido

typedef struct {
    float x, y;
    float radius;
    bool active;
} Ripple;

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

    srand(time(NULL));
    Ripple ripples[MAX_RIPPLES] = {0};

    // Reservamos memoria una sola vez para máxima eficiencia
    float *intensity_buffer = malloc(TERM_LINES * TERM_COLS * sizeof(float));
    // Búfer gigante para construir el texto de un frame entero (15 bytes por posible píxel)
    char *frame_output = malloc(TERM_LINES * TERM_COLS * 15);

    float spawn_chance_per_frame = DROP_RATE / (float)FPS;

    for(;;) {
        // 1. Generar nuevas gotas
        for(int i = 0; i < MAX_RIPPLES; i++) {
            if(!ripples[i].active) {
                float rand_val = (float)rand() / RAND_MAX;
                if (rand_val < spawn_chance_per_frame) {
                    ripples[i].x = (rand() % TERM_COLS) + 1;
                    ripples[i].y = (rand() % TERM_LINES) + 1;
                    ripples[i].radius = 0.0;
                    ripples[i].active = true;
                    break; // Solo intentamos crear una por ciclo para no saturar
                }
            }
        }

        // Limpiamos el mapa de intensidad
        memset(intensity_buffer, 0, TERM_LINES * TERM_COLS * sizeof(float));

        // 2. FÍSICA: Sumar las ondas al mapa de intensidad
        for(int i = 0; i < MAX_RIPPLES; i++) {
            if(!ripples[i].active) continue;

            // Crecer la onda
            ripples[i].radius += RIPPLE_SPEED;
            float rad = ripples[i].radius;

            // Disolución: Mientras más grande, más tenue (Fade factor)
            float fade = 1.0 - (rad * FADE_RATE);
            if (fade <= 0.0) {
                ripples[i].active = false; // La onda se ha disuelto por completo
                continue;
            }

            // Optimización: Solo calculamos matemáticas dentro de la "caja delimitadora" de la onda
            int min_c = (int)(ripples[i].x - rad - RING_WIDTH);
            int max_c = (int)(ripples[i].x + rad + RING_WIDTH);
            int min_r = (int)(ripples[i].y - (rad + RING_WIDTH) / 2.0); // Y es el doble de ancho
            int max_r = (int)(ripples[i].y + (rad + RING_WIDTH) / 2.0);

            if (min_c < 1) min_c = 1;
            if (max_c > TERM_COLS) max_c = TERM_COLS;
            if (min_r < 1) min_r = 1;
            if (max_r > TERM_LINES) max_r = TERM_LINES;

            for(int r = min_r; r <= max_r; r++) {
                for(int c = min_c; c <= max_c; c++) {
                    if (es_zona_prohibida(r, c)) continue;

                    float dx = (float)c - ripples[i].x;
                    float dy = ((float)r - ripples[i].y) * 2.0; // Corregir aspecto 2:1 de terminal
                    float dist = sqrt(dx*dx + dy*dy);
                    float diff = fabs(dist - rad);

                    // Si el píxel toca el anillo de la onda
                    if (diff < RING_WIDTH) {
                        // El centro del anillo es brillante (1.0), los bordes caen a 0.0
                        float local_intensity = 1.0 - (diff / RING_WIDTH);
                        // Aplicamos el nivel de vida/disolución general de la onda
                        float final_intensity = local_intensity * fade;
                        
                        // Sumamos la intensidad (así logramos patrones de interferencia)
                        intensity_buffer[(r - 1) * TERM_COLS + (c - 1)] += final_intensity;
                    }
                }
            }
        }

        // 3. RENDERIZADO AL MEGA-BÚFER
        int out_idx = 0;
        for(int r = 1; r <= TERM_LINES; r++) {
            bool cursor_needs_jump = true; // Controla los saltos ANSI
            for(int c = 1; c <= TERM_COLS; c++) {
                
                if (es_zona_prohibida(r, c)) {
                    cursor_needs_jump = true;
                    continue;
                }

                // Posicionamos el cursor de golpe solo si acabamos de saltar una zona prohibida o línea nueva
                if (cursor_needs_jump) {
                    out_idx += sprintf(frame_output + out_idx, "\033[%d;%dH", r, c);
                    cursor_needs_jump = false;
                }

                float val = intensity_buffer[(r - 1) * TERM_COLS + (c - 1)];
                
                // Mapear intensidad a carácter (multiplicamos para expandir la curva visual)
                int char_idx = (int)(val * 5.0);
                if (char_idx < 0) char_idx = 0;
                if (char_idx > CHARSET_LEN) char_idx = CHARSET_LEN;

                frame_output[out_idx++] = CHARSET[char_idx];
            }
        }
        frame_output[out_idx] = '\0'; // Finalizar la gran cadena

        // Mandar todo a la terminal de golpe
        printf("%s", frame_output);
        fflush(stdout);

        usleep(1000000 / FPS);
    }

    free(intensity_buffer);
    free(frame_output);
    return 0;
}

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/ioctl.h>

#define WIDTH 90
// Altura ajustada para no pisar las cajas inferiores
#define HEIGHT 35 
#define BUFFER_SIZE (WIDTH * HEIGHT)

int main(int argc, char *argv[]) {
    int start_y = 10; 
    if (argc >= 2) {
        start_y = atoi(argv[1]);
    }

    float A = 0, B = 0;
    float i, j;
    float z[BUFFER_SIZE];
    char b[BUFFER_SIZE];

    int fps = 15;      
    float rotX = 0.08; 
    float rotY = 0.04; 
    // Radio equilibrado
    float size = 45.0; 
    float R1 = 0.8;    
    float R2 = 1.6;    

    for(;;) {
        struct winsize w;
        int pad_left = 0;
        if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0) {
            pad_left = (w.ws_col - WIDTH) / 2;
            if (pad_left < 0) pad_left = 0; 
        }

        memset(b, 32, BUFFER_SIZE);
        memset(z, 0, BUFFER_SIZE * sizeof(float)); 
        
        for(j=0; j<6.28; j+=0.07) {
            for(i=0; i<6.28; i+=0.02) {
                float c = sin(i), d = cos(j), e = sin(A), f = sin(j), g = cos(A),
                      h = d * R1 + R2, 
                      D = 1 / (c * h * e + f * g + 5), 
                      l = cos(i), m = cos(B), n = sin(B), 
                      t = c * h * g - f * e;
                      
                int x = (WIDTH / 2) + size * D * (l * h * m - t * n),
                    y = (HEIGHT / 2) + (size / 2.0) * D * (l * h * n + t * m),
                    o = x + WIDTH * y;
                    
                int N = 8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n);
                
                if(HEIGHT > y && y > 0 && x > 0 && WIDTH > x && D > z[o]) {
                    z[o] = D;
                    b[o] = ".,-~:;=!*#$@"[N > 0 ? N : 0]; 
                }
            }
        }
        
        // ==========================================
        // LA MAGIA ANTI-SCROLL: Coordenadas absolutas
        // ==========================================
        for(int row = 0; row < HEIGHT; row++) {
            // Movemos el cursor a la fila (start_y + row) y columna (pad_left + 1)
            // Esto elimina por completo la necesidad de usar saltos de línea (\n)
            printf("\033[%d;%dH", start_y + row, pad_left + 1);
            for(int col = 0; col < WIDTH; col++) {
                putchar(b[row * WIDTH + col]);
            }
        }
        
        A += rotX;
        B += rotY;
        
        // Forzamos el renderizado inmediato para evitar parpadeos
        fflush(stdout); 
        usleep(1000000 / fps);
    }
    return 0;
}

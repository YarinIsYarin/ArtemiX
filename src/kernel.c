#include <stivale2.h>

static char* vgaptr = 0xb8000;

void terminal_printchar(char x, int row, int col) {
    vgaptr[2*(row*80 + col)] = x;
}

void terminal_print(char* str, int row, int col) {
    for (int i = 0; str[i]; i++ ) {
        terminal_printchar(str[i], row, col);
        row = (row + (col+1) / 80) % 25;
        col = (col+1) % 80; 
    }
}

void kmain(struct stivale2_struct* info) 
{
    terminal_print("Hello World!", 0, 0);
    while(1) { asm("hlt"); }
}
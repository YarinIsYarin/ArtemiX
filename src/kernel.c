#include <stivale2.h>

void kmain(struct stivale2_struct* info) 
{
    char* vgaptr = 0xb8000;
    vgaptr[0] = 'c';
    while(1) { asm("hlt"); }
}
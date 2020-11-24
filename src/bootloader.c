#include <stivale2.h>
#include <stddef.h>

extern void kmain(struct stivale2_struct* info);

static char stack[0x10000];

__attribute__((section(".stivale2hdr")))
struct stivale2_header stivale2_header = {
    .entry_point = (uint64_t)kmain,
    .stack       = (uintptr_t)stack + sizeof(stack),
    .flags       = 0,
    .tags        = (uint64_t)NULL
};
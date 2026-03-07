#include <stdio.h>
#include <stdint.h>

extern void quarter_round(uint32_t*, uint32_t*, uint32_t*, uint32_t*);

int main() {

    uint32_t a = 0x11111111;
    uint32_t b = 0x01020304;
    uint32_t c = 0x9b8d6f43;
    uint32_t d = 0x01234567;

    quarter_round(&a,&b,&c,&d);

    printf("Quarter round result:\n\n");

    printf("a = %08x\n", a);
    printf("b = %08x\n", b);
    printf("c = %08x\n", c);
    printf("d = %08x\n", d);

    return 0;
}
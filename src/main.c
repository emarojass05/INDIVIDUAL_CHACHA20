#include <stdio.h>
#include <stdint.h>
#include <string.h>

/* funciones en assembly */

extern void chacha20_quarter_round(
    uint32_t *a,
    uint32_t *b,
    uint32_t *c,
    uint32_t *d
);

extern void chacha20_block(
    uint32_t key[8],
    uint32_t counter,
    uint32_t nonce[3],
    uint32_t output[16]
);

extern void chacha20_encrypt(
    uint8_t *plaintext,
    uint8_t *ciphertext,
    uint32_t len,
    uint32_t key[8],
    uint32_t counter,
    uint32_t nonce[3]
);

int main() {

    printf("=== Test Quarter Round ===\n\n");

    uint32_t a = 0x11111111;
    uint32_t b = 0x01020304;
    uint32_t c = 0x9b8d6f43;
    uint32_t d = 0x01234567;

    chacha20_quarter_round(&a,&b,&c,&d);

    printf("a = %08x\n",a);
    printf("b = %08x\n",b);
    printf("c = %08x\n",c);
    printf("d = %08x\n",d);

    printf("\n=== Test ChaCha20 Block ===\n\n");

    uint32_t key[8] = {
        0x03020100,
        0x07060504,
        0x0b0a0908,
        0x0f0e0d0c,
        0x13121110,
        0x17161514,
        0x1b1a1918,
        0x1f1e1d1c
    };

    uint32_t nonce[3] = {
        0x09000000,
        0x4a000000,
        0x00000000
    };

    uint32_t counter = 1;
    uint32_t output[16];

    chacha20_block(key,counter,nonce,output);

    for(int i=0;i<16;i++)
        printf("%08x\n",output[i]);

    printf("\n=== Test ChaCha20 Encrypt ===\n\n");

    uint8_t plaintext[] = "Hello ChaCha20 encryption!";
    uint8_t ciphertext[128];

    memset(ciphertext,0,sizeof(ciphertext));

    chacha20_encrypt(
        plaintext,
        ciphertext,
        strlen((char*)plaintext),
        key,
        counter,
        nonce
    );

    printf("Plaintext:\n%s\n\n",plaintext);

    printf("Ciphertext (hex):\n");

    for(int i=0;i<strlen((char*)plaintext);i++)
        printf("%02x ",ciphertext[i]);

    printf("\n");

    return 0;
}
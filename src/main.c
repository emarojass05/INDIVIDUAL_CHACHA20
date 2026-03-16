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

void print_hex(uint8_t *data, int len)
{
    for(int i = 0; i < len; i++)
        printf("%02x ", data[i]);
    printf("\n");
}

int main()
{
    printf("=== Test Quarter Round ===\n\n");

    uint32_t a = 0x11111111;
    uint32_t b = 0x01020304;
    uint32_t c = 0x9b8d6f43;
    uint32_t d = 0x01234567;

    chacha20_quarter_round(&a, &b, &c, &d);

    printf("a = %08x\n", a);
    printf("b = %08x\n", b);
    printf("c = %08x\n", c);
    printf("d = %08x\n\n", d);


    printf("=== Test ChaCha20 Block ===\n\n");

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

    chacha20_block(key, counter, nonce, output);

    for(int i = 0; i < 16; i++)
        printf("%08x\n", output[i]);


    printf("\n=== Test ChaCha20 Encrypt ===\n\n");

    uint8_t plaintext[] =
        "ChaCha20 implementation in RISC-V assembly for Computer Architecture course. "
        "This message is intentionally longer than 128 bytes so we test multiple blocks "
        "of the cipher and verify the counter increments correctly.";

    int len = strlen((char*)plaintext);

    uint8_t ciphertext[512];
    uint8_t decrypted[512];

    memset(ciphertext, 0, sizeof(ciphertext));
    memset(decrypted, 0, sizeof(decrypted));

    printf("Plaintext:\n%s\n\n", plaintext);

    chacha20_encrypt(
        plaintext,
        ciphertext,
        len,
        key,
        counter,
        nonce
    );

    printf("=== Test Encrypt ===\n");
    print_hex(ciphertext, len);


    printf("\n=== Test ChaCha20 Decrypt ===\n\n");

    /* reiniciar contador para generar el mismo keystream */
    counter = 1;

    chacha20_encrypt(
        ciphertext,
        decrypted,
        len,
        key,
        counter,
        nonce
    );

    decrypted[len] = '\0';

    printf("Decrypted text:\n%s\n\n", decrypted);

    if(strcmp((char*)plaintext, (char*)decrypted) == 0)
        printf("SUCCESS: plaintext recovered correctly\n");
    else
        printf("ERROR: decryption failed\n");

    return 0;
}
.section .text
.globl chacha20_encrypt
.type chacha20_encrypt,@function

.extern chacha20_block

# a0 plaintext
# a1 ciphertext
# a2 length
# a3 key
# a4 counter
# a5 nonce

chacha20_encrypt:

    addi sp,sp,-256
    sd ra,248(sp)

# buffer para keystream
    addi t0,sp,0

encrypt_done:

    ld ra,248(sp)
    addi sp,sp,256
    ret
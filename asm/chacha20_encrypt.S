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

# keystream buffer
    addi t0,sp,0

encrypt_loop:

    beq a2,zero,encrypt_done

# generar bloque keystream

    mv a0,a3
    mv a1,a4
    mv a2,a5
    addi a3,sp,0

    call chacha20_block

encrypt_done:

    ld ra,248(sp)
    addi sp,sp,256
    ret
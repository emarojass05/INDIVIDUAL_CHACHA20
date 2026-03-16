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

    addi sp,sp,-128

    sd ra,120(sp)
    sd s0,112(sp)
    sd s1,104(sp)
    sd s2,96(sp)
    sd s3,88(sp)
    sd s4,80(sp)
    sd s5,72(sp)

    mv s0,a0      # plaintext
    mv s1,a1      # ciphertext
    mv s2,a2      # remaining length
    mv s3,a4      # current counter
    mv s4,a5      # nonce
    mv s5,a4      # original counter

encrypt_loop:

    beq s2,zero,encrypt_done

    mv a0,a3
    mv a1,s3
    mv a2,s4
    addi a3,sp,0

    call chacha20_block

    li t0,64
    blt s2,t0,block_len_ok
    mv t1,t0
    j xor_start

block_len_ok:
    mv t1,s2

xor_start:

    mv t2,s0
    mv t3,s1
    addi t4,sp,0
    li t5,0

xor_loop:

    bge t5,t1,next_block

    lbu t6,0(t2)
    lbu t0,0(t4)

    xor t6,t6,t0

    sb t6,0(t3)

    addi t2,t2,1
    addi t3,t3,1
    addi t4,t4,1

    addi t5,t5,1
    j xor_loop

next_block:

    add s0,s0,t1
    add s1,s1,t1
    sub s2,s2,t1

    addi s3,s3,1

    j encrypt_loop

encrypt_done:

    ld s5,72(sp)
    ld s4,80(sp)
    ld s3,88(sp)
    ld s2,96(sp)
    ld s1,104(sp)
    ld s0,112(sp)
    ld ra,120(sp)

    addi sp,sp,128
encrypt_end: 
    ret
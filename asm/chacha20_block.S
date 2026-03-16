.section .text

.globl chacha20_block
.type chacha20_block, @function

.extern chacha20_quarter_round

# ------------------------------------------------
# void chacha20_block(uint32_t key[8],
#                     uint32_t counter,
#                     uint32_t nonce[3],
#                     uint32_t output[16])
#
# a0 = key
# a1 = counter
# a2 = nonce
# a3 = output
# ------------------------------------------------

chacha20_block:

    addi sp, sp, -192

    sd ra, 184(sp)
    sd s0, 176(sp)
    sd s1, 168(sp)
    sd a3, 160(sp)

##################################################
# Construcción del state inicial
##################################################

    li t0,0x61707865
    sw t0,0(sp)

    li t0,0x3320646e
    sw t0,4(sp)

    li t0,0x79622d32
    sw t0,8(sp)

    li t0,0x6b206574
    sw t0,12(sp)

# key

    lw t0,0(a0)
    sw t0,16(sp)

    lw t0,4(a0)
    sw t0,20(sp)

    lw t0,8(a0)
    sw t0,24(sp)

    lw t0,12(a0)
    sw t0,28(sp)

    lw t0,16(a0)
    sw t0,32(sp)

    lw t0,20(a0)
    sw t0,36(sp)

    lw t0,24(a0)
    sw t0,40(sp)

    lw t0,28(a0)
    sw t0,44(sp)

# counter

    sw a1,48(sp)

# nonce

    lw t0,0(a2)
    sw t0,52(sp)

    lw t0,4(a2)
    sw t0,56(sp)

    lw t0,8(a2)
    sw t0,60(sp)

##################################################
# Copiar state → working_state
##################################################

    li t1,0
    li t6,16

copy_loop:

    bge t1,t6,copy_done

    slli t2,t1,2

    add t3,sp,t2
    lw t4,0(t3)

    addi t5,sp,64
    add t5,t5,t2

    sw t4,0(t5)

    addi t1,t1,1
    j copy_loop

copy_done:

##################################################
# 20 rounds (10 double rounds)
##################################################

    li s0,0
    li s1,10

round_loop:

    bge s0,s1,round_done

# column rounds

    addi a0,sp,64
    addi a1,sp,80
    addi a2,sp,96
    addi a3,sp,112
    call chacha20_quarter_round

    addi a0,sp,68
    addi a1,sp,84
    addi a2,sp,100
    addi a3,sp,116
    call chacha20_quarter_round

    addi a0,sp,72
    addi a1,sp,88
    addi a2,sp,104
    addi a3,sp,120
    call chacha20_quarter_round

    addi a0,sp,76
    addi a1,sp,92
    addi a2,sp,108
    addi a3,sp,124
    call chacha20_quarter_round

# diagonal rounds

    addi a0,sp,64
    addi a1,sp,84
    addi a2,sp,104
    addi a3,sp,124
    call chacha20_quarter_round

    addi a0,sp,68
    addi a1,sp,88
    addi a2,sp,108
    addi a3,sp,112
    call chacha20_quarter_round

    addi a0,sp,72
    addi a1,sp,92
    addi a2,sp,96
    addi a3,sp,116
    call chacha20_quarter_round

    addi a0,sp,76
    addi a1,sp,80
    addi a2,sp,100
    addi a3,sp,120
    call chacha20_quarter_round

    addi s0,s0,1
    j round_loop

round_done:

##################################################
# working_state += state
##################################################

    li t1,0

add_loop:

    bge t1,t6,add_done

    slli t2,t1,2

    add t3,sp,t2
    lw t4,0(t3)

    addi t5,sp,64
    add t5,t5,t2
    lw t0,0(t5)

    addw t0,t0,t4
    sw t0,0(t5)

    addi t1,t1,1
    j add_loop

add_done:

##################################################
# copiar resultado → output
##################################################

    ld a3,160(sp)

    li t1,0

store_loop:

    bge t1,t6,store_done

    slli t2,t1,2

    addi t3,sp,64
    add t3,t3,t2

    lw t4,0(t3)

    sw t4,0(a3)

    addi a3,a3,4
    addi t1,t1,1

    j store_loop

store_done:

##################################################
# restaurar stack
##################################################

    ld s1,168(sp)
    ld s0,176(sp)
    ld ra,184(sp)

    addi sp,sp,192
block_end:
    ret
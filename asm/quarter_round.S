.section .text

.globl chacha20_quarter_round
.type chacha20_quarter_round,@function

chacha20_quarter_round:

    lw t0,0(a0)
    lw t1,0(a1)
    lw t2,0(a2)
    lw t3,0(a3)

# a += b
# d ^= a
# d <<< 16

    addw t0,t0,t1
    xor  t3,t3,t0

    slliw t4,t3,16
    srliw t5,t3,16
    or   t3,t4,t5
    addiw t3,t3,0

# c += d
# b ^= c
# b <<< 12

    addw t2,t2,t3
    xor  t1,t1,t2

    slliw t4,t1,12
    srliw t5,t1,20
    or   t1,t4,t5
    addiw t1,t1,0

# a += b
# d ^= a
# d <<< 8

    addw t0,t0,t1
    xor  t3,t3,t0

    slliw t4,t3,8
    srliw t5,t3,24
    or   t3,t4,t5
    addiw t3,t3,0

# c += d
# b ^= c
# b <<< 7

    addw t2,t2,t3
    xor  t1,t1,t2

    slliw t4,t1,7
    srliw t5,t1,25
    or   t1,t4,t5
    addiw t1,t1,0

    sw t0,0(a0)
    sw t1,0(a1)
    sw t2,0(a2)
    sw t3,0(a3)
quarter_round_end:
    ret
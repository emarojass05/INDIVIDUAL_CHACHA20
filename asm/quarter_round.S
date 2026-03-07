.section .text
.globl quarter_round

quarter_round:

    # a0 = &a
    # a1 = &b
    # a2 = &c
    # a3 = &d

    lw t0, 0(a0)
    lw t1, 0(a1)
    lw t2, 0(a2)
    lw t3, 0(a3)

    # a += b
    addw t0, t0, t1

    # d ^= a
    xor t3, t3, t0

    # d <<< 16
    slliw t4, t3, 16
    srliw t5, t3, 16
    or t3, t4, t5

    # c += d
    addw t2, t2, t3

    # b ^= c
    xor t1, t1, t2

    # b <<< 12
    slliw t4, t1, 12
    srliw t5, t1, 20
    or t1, t4, t5

    # a += b
    addw t0, t0, t1

    # d ^= a
    xor t3, t3, t0

    # d <<< 8
    slliw t4, t3, 8
    srliw t5, t3, 24
    or t3, t4, t5

    # c += d
    addw t2, t2, t3

    # b ^= c
    xor t1, t1, t2

    # b <<< 7
    slliw t4, t1, 7
    srliw t5, t1, 25
    or t1, t4, t5

    sw t0, 0(a0)
    sw t1, 0(a1)
    sw t2, 0(a2)
    sw t3, 0(a3)

    ret
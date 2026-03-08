CC=riscv64-linux-gnu-gcc

CFLAGS=-Wall -g -static

SRC=src/main.c \
    asm/quarter_round.S \
    asm/chacha20_block.S \
    asm/chacha20_encrypt.S

TARGET=main


all:
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

run:
	qemu-riscv64 ./main

clean:
	rm -f $(TARGET)
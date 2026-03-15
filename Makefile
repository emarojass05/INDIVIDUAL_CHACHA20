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
	pkill qemu-riscv64 2>/dev/null || true
	qemu-riscv64 -g 1234 ./$(TARGET)

normal:
	qemu-riscv64 ./$(TARGET)


debug:
	gdb-multiarch $(TARGET)


clean:
	rm -f $(TARGET)
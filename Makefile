CC=riscv64-linux-gnu-gcc

all:
	$(CC) -Wall -g -static src/main.c asm/quarter_round.S -o main

run:
	qemu-riscv64 ./main

clean:
	rm -f main

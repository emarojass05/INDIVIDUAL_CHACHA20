all:
	riscv64-linux-gnu-gcc -Wall -g -static src/main.c asm/chacha20_block.S asm/quarter_round.S -o main

run:
	qemu-riscv64 ./main

clean:
	rm -f main
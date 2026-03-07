#!/usr/bin/env bash
set -euo pipefail

echo "Building bare-metal assembly example..."

riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g \
    test.s \
    -T linker.ld \
    -o test.elf

echo "Build successful: test.elf created"
# Documentación Técnica — Implementación de ChaCha20 en RISC-V

## 1. Introducción

Este documento describe el diseño e implementación del algoritmo ChaCha20 utilizando ensamblador RISC-V.

El objetivo del proyecto es comprender cómo implementar primitivas criptográficas de bajo nivel y cómo interactúan con programas escritos en C.

La implementación sigue la especificación definida en:

RFC 8439  
https://datatracker.ietf.org/doc/html/rfc8439

---

# 2. Descripción del algoritmo ChaCha20

ChaCha20 es un cifrador de flujo diseñado por **Daniel J. Bernstein**.

El algoritmo genera un **keystream de 64 bytes** que luego se combina con el texto plano mediante XOR.

La estructura del estado ChaCha20 consiste en **16 palabras de 32 bits**:

```
constant constant constant constant
key      key      key      key
key      key      key      key
counter  nonce    nonce    nonce
```

Cada bloque se procesa mediante **20 rondas**, organizadas como:

- 10 column rounds
- 10 diagonal rounds

La operación fundamental del algoritmo es el **quarter round**.

---

# 3. Quarter Round

El quarter round mezcla cuatro palabras de 32 bits.

Operaciones:

```
a += b; d ^= a; d <<< 16
c += d; b ^= c; b <<< 12
a += b; d ^= a; d <<< 8
c += d; b ^= c; b <<< 7
```

Esta operación introduce difusión y no linealidad en el estado.

La implementación se encuentra en:

```
asm/quarter_round.S
```

---

# 4. ChaCha20 Block Function

La función `chacha20_block` genera un bloque de keystream de 64 bytes.

Pasos principales:

1. Construir el estado inicial
2. Copiar el estado a un working state
3. Ejecutar 20 rondas
4. Sumar el estado original al working state
5. Escribir el resultado

Archivo:

```
asm/chacha20_block.S
```

---

# 5. ChaCha20 Encryption

El cifrado se realiza combinando el keystream con el texto plano:

```
ciphertext = plaintext XOR keystream
```

La función:

```
chacha20_encrypt
```

se encarga de:

- generar bloques de keystream
- aplicar XOR sobre el mensaje

Archivo:

```
asm/chacha20_encrypt.S
```

---

# 6. Convenciones de llamada RISC-V

La implementación respeta la convención de llamada estándar de RISC-V.

Registros importantes:

| Registro | Uso |
|--------|------|
| a0-a7 | parámetros |
| t0-t6 | temporales |
| s0-s11 | preservados |
| ra | dirección de retorno |
| sp | stack pointer |

Las funciones en ensamblador:

- reciben parámetros en `a0–a3`
- retornan valores en `a0`

---

# 7. Integración con C

El archivo:

```
src/main.c
```

permite ejecutar pruebas del algoritmo.

El programa prueba:

1. quarter round
2. chacha20 block
3. cifrado completo

Esto facilita verificar que la implementación coincide con los vectores del RFC.

---

# 8. Ejecución en QEMU

El proyecto se ejecuta utilizando el emulador RISC-V:

```
qemu-riscv64 ./main
```

Esto permite ejecutar código RISC-V en una máquina x86.

---

# 9. Ejecución Bare Metal

El repositorio incluye un ejemplo de ejecución bare-metal en:

```
examples/baremetal
```

Este ejemplo ejecuta código ensamblador sin sistema operativo.

Proceso:

1. compilar con `riscv64-unknown-elf-gcc`
2. generar archivo ELF
3. ejecutar en `qemu-system-riscv32`

Esto permite observar la ejecución a nivel de hardware.

---

# 10. Depuración con GDB

El proyecto permite depurar usando:

```
gdb-multiarch
```

Conectándose a QEMU mediante:

```
target remote :1234
```

Esto permite:

- inspeccionar registros
- ejecutar instrucciones paso a paso
- observar el flujo del programa

---

# 11. Resultados

Las pruebas ejecutadas coinciden con los vectores de prueba definidos en el RFC.

Ejemplo de salida del block function:

```
10f1e7e4
d13b5915
500fdd1f
a32071c4
...
```

Esto confirma que la implementación es correcta.

---

# 12. Conclusiones

El proyecto demuestra que es posible implementar algoritmos criptográficos modernos en ensamblador RISC-V manteniendo eficiencia y claridad.

Además permite comprender:

- cómo funciona ChaCha20 internamente
- cómo se implementan rotaciones y mezclas de bits
- cómo interactúan C y assembly
- cómo depurar programas de bajo nivel.

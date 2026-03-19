# Documentación Técnica — Implementación de ChaCha20 en RISC-V

## 1. Introducción

Este documento describe el diseño e implementación del algoritmo ChaCha20 utilizando ensamblador RISC-V.

El objetivo del proyecto es comprender cómo implementar primitivas criptográficas de bajo nivel y cómo interactúan con programas escritos en C.

---

# 2. Descripción del algoritmo ChaCha20

ChaCha20 es un cifrador de flujo diseñado por Daniel J. Bernstein.

El algoritmo genera un keystream de 64 bytes que luego se combina con el texto plano mediante XOR.

La estructura del estado ChaCha20 consiste en 16 palabras de 32 bits:

```
constant constant constant constant  
key key key key  
key key key key  
counter nonce nonce nonce  
```

Cada bloque se procesa mediante 20 rondas organizadas como:

- 10 column rounds
- 10 diagonal rounds

Estas rondas aplican operaciones ARX (Addition, Rotation, XOR), las cuales proporcionan difusión y seguridad criptográfica.

La operación fundamental del algoritmo es el quarter round.

---

## 3. Quarter Round

El quarter round es la operación fundamental del algoritmo ChaCha20.  
Esta operación mezcla cuatro palabras de 32 bits utilizando operaciones de suma modular, XOR y rotaciones de bits.

Las operaciones que definen el quarter round son:

```
a += b; d ^= a; d <<< 16  
c += d; b ^= c; b <<< 12  
a += b; d ^= a; d <<< 8  
c += d; b ^= c; b <<< 7  
```

Estas operaciones introducen difusión y no linealidad en el estado interno del algoritmo.

La implementación de esta función se encuentra en:

```
asm/quarter_round.S
```

---

## Implementación de rotaciones en RISC-V

El algoritmo ChaCha20 utiliza rotaciones de bits sobre palabras de 32 bits.  
Sin embargo, la ISA base de RISC-V no incluye una instrucción de rotación directa, por lo que estas se implementan utilizando instrucciones de desplazamiento lógico y una operación OR.

Una rotación a la izquierda se implementa como:

```
(x <<< n) = (x << n) | (x >> (32 − n))
```

Ejemplo en ensamblador:

```
slliw t4,t1,7  
srliw t5,t1,25  
or t1,t4,t5  
```

Las instrucciones terminadas en **`w`** operan sobre palabras de **32 bits**, lo cual coincide con el tamaño de las palabras utilizadas por el algoritmo.

ChaCha20 se basa en el modelo ARX (Addition, Rotation, XOR), eficiente en arquitecturas RISC.

---

## Evidencia de ejecución

Las siguientes capturas muestran la ejecución del quarter round y su verificación:

![](images/quarter_round.png)

![](images/print_quarter_round.png)

---

# 4. ChaCha20 Block Function

La función `chacha20_block` genera un bloque de keystream de 64 bytes.

Pasos principales del algoritmo:

1. Construir el estado inicial  
2. Copiar el estado a un working state  
3. Ejecutar 20 rondas  
4. Sumar el estado original al working state  
5. Escribir el resultado en memoria  

Archivo:

```
asm/chacha20_block.S
```

Durante la depuración se verificó:

Estado inicial:

![](images/ini_block_chacha20.png)

Estado después de 20 rondas:

![](images/20round.png)

---

# 5. ChaCha20 Encryption

El cifrado se realiza mediante:

```
ciphertext = plaintext XOR keystream
```

La función `chacha20_encrypt`:

- genera bloques de keystream
- aplica XOR
- incrementa el contador por bloque

Archivo:

```
asm/chacha20_encrypt.S
```

Evidencias:

![](images/entry_chacha20.png)

![](images/encrypt.png)

---

# 6. Mapeo del estado ChaCha20 a registros RISC-V

El estado consiste en 16 palabras de 32 bits.

Registros utilizados:

```
a0–a5  → parámetros  
t0–t6  → temporales  
s0–s5  → preservados  
ra     → retorno  
sp     → stack pointer  
```

El estado se almacena en el stack frame, permitiendo acceso indexado eficiente.

---

# 7. Manejo del Stack Frame

Cada función crea su stack frame.

Ejemplo:

```
addi sp,sp,-128  
sd ra,120(sp)  
sd s0,112(sp)  
```

Uso del stack:

- guardar registros
- almacenar keystream temporal
- manejar estructuras

Restauración:

```
ld ra,120(sp)  
addi sp,sp,128  
ret  
```

---

# 8. Integración con C

El archivo `src/main.c` ejecuta pruebas:

1. Quarter round  
2. Block function  
3. Cifrado completo  

Además, se valida contra el RFC.

---

# 9. Ejecución en QEMU

El programa se ejecuta con:

```
qemu-riscv64 ./main
```

Esto permite correr código RISC-V en arquitectura x86.

---

# 10. Depuración con GDB

Se utiliza:

```
gdb-multiarch
```

Conexión:

```
target remote :1234
```

Permite:

- inspeccionar registros
- ejecutar paso a paso
- validar estados internos

Breakpoints:

```
break chacha20_encrypt  
break chacha20_block  
break chacha20_quarter_round  
```

---

# 11. Resultados

Los resultados coinciden con los vectores oficiales del RFC.

Ejemplo:

```
10f1e7e4  
d13b5915  
500fdd1f  
a32071c4  
```

Además, el keystream del Appendix A.1 coincide exactamente:

```
76 b8 e0 ad a0 f1 3d 90 ...
```

Esto confirma la correcta implementación.

---

# 12. Bitácora de bug

Se detectó un error en el manejo del contador.

Problema:

- el contador no se reiniciaba antes del descifrado

Efecto:

- keystream incorrecto
- texto corrupto

Solución:

- restaurar contador antes de descifrar

El error fue identificado mediante GDB, cabe recalcar que no hay foto del bug porque fue encontrado con anterioridad y no se le tomo foto por lo mismo.

---

# 13. Conclusiones

Se logró implementar ChaCha20 correctamente en ensamblador RISC-V.

Se comprendieron:

- operaciones ARX
- manejo de registros y stack
- integración C + Assembly
- depuración con herramientas reales

La implementación coincide con el RFC, validando su correcta funcionalidad.

---

# 14. Referencias

- RFC 8439 — ChaCha20 and Poly1305 for IETF Protocols  
  https://www.rfc-editor.org/rfc/rfc8439

- The RISC-V Instruction Set Manual  
  https://riscv.org/technical/specifications/

- Patterson, D. A., & Hennessy, J. L.  
  Computer Organization and Design RISC-V Edition

- QEMU Documentation  
  https://www.qemu.org/docs/

- GDB Documentation  
  https://sourceware.org/gdb/documentation/
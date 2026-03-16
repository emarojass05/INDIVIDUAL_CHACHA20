# Implementación de ChaCha20 en Ensamblador RISC-V

## Autor

Emmanuel Rojas Fernández  
Instituto Tecnológico de Costa Rica  
Ingeniería en Computadores  

Curso: Arquitectura de Computadores I

---

# 1. Descripción del proyecto

Este proyecto implementa el algoritmo criptográfico **ChaCha20** utilizando **ensamblador RISC-V**, integrando código en **C y Assembly**.

El objetivo del proyecto es demostrar conocimientos en:

- Convenciones de llamada de RISC-V
- Manejo eficiente de registros
- Implementación de algoritmos criptográficos a bajo nivel
- Integración entre C y ensamblador
- Depuración utilizando GDB y QEMU

El algoritmo ChaCha20 está definido en el **RFC 8439** y se basa en operaciones simples y eficientes:

- suma modular de 32 bits
- operación XOR
- rotaciones de bits

El proyecto implementa las siguientes funciones principales:

- `quarter_round`
- `chacha20_block`
- `chacha20_encrypt`

El programa principal en C permite probar cada una de estas funciones y verificar su funcionamiento.

---

# 2. Estructura del repositorio

```
INDIVIDUAL_CHACHA20
│
├── asm
│   ├── quarter_round.S        # Implementación del quarter round
│   ├── chacha20_block.S       # Implementación del bloque ChaCha20
│   └── chacha20_encrypt.S     # Implementación del cifrado completo
│
├── src
│   └── main.c                 # Programa principal en C
│
├── examples
│   └── baremetal              # Ejemplo de ejecución bare-metal
│       ├── test.s
│       ├── linker.ld
│       ├── build.sh
│       └── run-qemu.sh
│
├── scripts
│   ├── build-image.sh         # Construcción de la imagen Docker
│   └── run-container.sh       # Ejecución del contenedor
│
├── docker
│   └── Dockerfile             # Entorno de desarrollo RISC-V
│
├── tests
│
├── Makefile                   # Sistema de compilación
│
├── README.md
└── DOCUMENTACION.md
```

---

# 3. Requisitos previos

Para ejecutar el proyecto se requiere:

## Docker

Docker se utiliza para reproducir el entorno de desarrollo utilizado en el curso.

Instalar Docker en Ubuntu:

```bash
sudo apt install docker.io
```

Activar el servicio:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Agregar el usuario al grupo docker:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verificar instalación:

```bash
docker --version
```

---

## Toolchain RISC-V

El proyecto utiliza:

```
riscv64-linux-gnu-gcc
```

Dentro del contenedor Docker se utiliza:

```
riscv64-unknown-elf-gcc
```

---

## QEMU

Para ejecutar programas RISC-V:

```
qemu-riscv64
```

Para ejecutar en modo bare metal:

```
qemu-system-riscv32
```

---

# 4. Construcción del entorno Docker

Construir la imagen Docker desde la raíz del proyecto:

```bash
./scripts/build-image.sh
```

Esto crea una imagen con:

- Toolchain RISC-V
- QEMU
- GDB
- entorno completo de compilación

---

# 5. Ejecutar el contenedor Docker

Ejecutar:

```bash
./scripts/run-container.sh
```

Esto abrirá una terminal dentro del contenedor.

Ejemplo:

```
[rvqemu-dev@container workspace]$
```

---

# 6. Compilar el proyecto

Dentro del contenedor o en el entorno configurado ejecutar:

```bash
make
```

Esto compila los siguientes archivos:

```
src/main.c
asm/quarter_round.S
asm/chacha20_block.S
asm/chacha20_encrypt.S
```

Se genera el ejecutable:

```
main
```

---

# 7. Ejecutar el programa

Para ejecutar el programa:

```bash
make run
```

Esto ejecuta el programa con el emulador RISC-V:

```bash
qemu-riscv64 ./main
```

Salida esperada:

```
=== Test Quarter Round ===

a = ea2a92f4
b = cb1cf8ce
c = 4581472e
d = 5881c4bb

=== Test ChaCha20 Block ===

e4e7f110
15593bd1
1fdd0f50
c47120a3
...

=== Test ChaCha20 Encrypt ===

Plaintext:
Hello ChaCha20 encryption!

Ciphertext (hex):
...
```

---

# 8. Verificación con vectores del RFC

El proyecto utiliza los vectores de prueba definidos en **RFC 8439**.

Vector de prueba para quarter round:

Entrada:

```
a = 0x11111111
b = 0x01020304
c = 0x9b8d6f43
d = 0x01234567
```

Salida esperada:

```
a = 0xea2a92f4
b = 0xcb1cf8ce
c = 0x4581472e
d = 0x5881c4bb
```

Si el programa produce estos valores, la implementación es correcta.

---

# 9. Ejecución en modo Bare Metal

El repositorio incluye un ejemplo para ejecutar código en modo **bare metal**.

## Paso 1 — Entrar al contenedor

```bash
docker exec -it rvqemu /bin/bash
```

## Paso 2 — Ir al ejemplo bare metal

```bash
cd /home/rvqemu-dev/workspace/examples/baremetal
```

## Paso 3 — Compilar el programa

```bash
./build.sh
```

Esto genera:

```
test.elf
```

## Paso 4 — Ejecutar QEMU

```bash
./run-qemu.sh
```

Esto inicia QEMU con un servidor de depuración GDB en el puerto:

```
1234
```

---

# 10. Depuración con GDB

En otra terminal ejecutar:

```bash
docker exec -it rvqemu /bin/bash
cd /home/rvqemu-dev/workspace/examples/baremetal
gdb-multiarch test.elf
```

Conectar con QEMU:

```bash
target remote :1234
```

Comandos útiles:

Mostrar registros:

```bash
info registers
```

Ejecutar instrucción por instrucción:

```bash
stepi
```

Colocar breakpoint:

```bash
break _start
continue
```

Mostrar el código ensamblador:

```bash
layout asm
```

Mostrar los registros en pantalla:

```bash
layout regs
```

Esto permite observar cómo cambian los registros durante la ejecución del programa.

---

# 11. Referencias

ChaCha20 está definido en:

RFC 8439  
https://datatracker.ietf.org/doc/html/rfc8439

---
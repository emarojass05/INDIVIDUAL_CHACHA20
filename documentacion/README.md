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
- Depuración utilizando **GDB y QEMU**

El algoritmo ChaCha20 está definido en el **RFC 8439** y se basa en operaciones simples y eficientes:

- suma modular de 32 bits
- operación XOR
- rotaciones de bits

El proyecto implementa las siguientes funciones principales:

- `chacha20_quarter_round`
- `chacha20_block`
- `chacha20_encrypt`

Estas funciones están implementadas completamente en **ensamblador RISC-V**, mientras que el programa principal está escrito en **C** y se encarga de ejecutar pruebas y verificar los resultados.

---

# 2. Arquitectura del software

El proyecto se divide en dos capas:

## C (control y pruebas)

El archivo `main.c` se encarga de:

- preparar los datos de prueba
- llamar a las funciones en ensamblador
- imprimir resultados
- verificar la corrección del algoritmo

## Assembly (implementación del algoritmo)

Las funciones críticas del algoritmo se implementan en ensamblador.

Flujo de ejecución del programa:

```
main.c
   ↓
chacha20_encrypt
   ↓
chacha20_block
   ↓
chacha20_quarter_round
```

Cada bloque ChaCha20 ejecuta **20 rondas** que transforman el estado interno del cifrado.

---

# 3. Estructura del repositorio

```
INDIVIDUAL_CHACHA20
│
├── asm
│   ├── quarter_round.S
│   ├── chacha20_block.S
│   └── chacha20_encrypt.S
│
├── src
│   └── main.c
│
├── examples
│   └── baremetal
│       ├── test.s
│       ├── linker.ld
│       ├── build.sh
│       └── run-qemu.sh
│
├── scripts
│   ├── build-image.sh
│   └── run-container.sh
│
├── docker
│   └── Dockerfile
│
├── tests
│
├── Makefile
│
├── README.md
└── DOCUMENTACION.md
```

---

# 4. Requisitos previos

Para ejecutar el proyecto se requiere:

- Docker
- QEMU
- Toolchain RISC-V
- GDB multiarch

---

## Docker

Instalar Docker en Ubuntu:

```bash
sudo apt install docker.io
```

Activar el servicio:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Agregar usuario al grupo docker:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verificar instalación:

```bash
docker --version
```

---

# 5. Toolchain RISC-V

El proyecto ChaCha20 se compila con:

```
riscv64-linux-gnu-gcc
```

Este compilador permite utilizar funciones estándar de C como:

- `printf`
- `strlen`

El ejemplo incluido en `examples/baremetal` utiliza en cambio:

```
riscv64-unknown-elf-gcc
```

porque se ejecuta en **modo bare-metal sin sistema operativo**.

---

# 6. Construcción del entorno Docker

Desde la raíz del proyecto ejecutar:

```bash
./scripts/build-image.sh
```

Esto construye una imagen Docker con:

- toolchain RISC-V
- QEMU
- GDB
- dependencias necesarias para compilar

---

# 7. Ejecutar el contenedor Docker

Ejecutar:

```bash
./scripts/run-container.sh
```

Esto abrirá una terminal dentro del contenedor:

```
[rvqemu-dev@container workspace]$
```

---

# 8. Compilar el proyecto

Dentro del contenedor ejecutar:

```bash
make
```

Esto compila los archivos:

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

# 9. Ejecutar el programa

Para ejecutar el programa:

```bash
make run
```

Esto ejecuta el programa utilizando el emulador:

```
qemu-riscv64 ./main
```

Salida esperada:

```
=== Test Quarter Round ===

a = ea2a92f4
b = cb1cf8ce
c = 4581472e
d = 5881c4bb
```

---

# 10. Ejecución de los casos de prueba

El programa ejecuta tres pruebas principales.

### Quarter Round

Verifica la operación básica del algoritmo usando los valores definidos en el RFC.

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

### ChaCha20 Block

Genera un bloque de keystream utilizando la función `chacha20_block`.

### ChaCha20 Encrypt

Cifra un mensaje utilizando el algoritmo completo.

Si la implementación es correcta, el programa mostrará:

```
SUCCESS: plaintext recovered correctly
```

---

# 11. Depuración con GDB

El proyecto permite depurar la ejecución utilizando **QEMU y GDB**.

## Terminal 1

Ejecutar el programa con soporte de depuración:

```bash
make run
```

Esto inicia QEMU con un servidor GDB en el puerto:

```
1234
```

---

## Terminal 2

Abrir GDB:

```bash
make debug
```

Conectar con el programa:

```bash
target remote :1234
```

Continuar ejecución:

```bash
continue
```

---

## Breakpoints útiles

```bash
break main
break chacha20_encrypt
break chacha20_block
break chacha20_quarter_round
break encrypt_end
```

---

## Comandos útiles en GDB

Mostrar registros:

```bash
info registers
```

Ejecutar una instrucción:

```bash
stepi
```

Mostrar memoria del stack:

```bash
x/32x $sp
```

Mostrar código ensamblador:

```bash
layout asm
```

Mostrar registros en pantalla:

```bash
layout regs
```

---

# 12. Referencias

ChaCha20 está definido en: RFC 8439

https://www.rfc-editor.org/rfc/rfc8439
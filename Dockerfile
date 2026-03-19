ARG UID=1000
ARG GID=1000
ARG USERNAME=rvqemu-dev

FROM ubuntu:22.04

ARG UID
ARG GID
ARG USERNAME

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        git \
        build-essential \
        python3 python3-pip python3-venv \
        pkg-config \
        libglib2.0-dev \
        libpixman-1-dev \
        ninja-build \
        wget curl sudo \
        make \
        gcc-riscv64-unknown-elf \
        gcc-riscv64-linux-gnu \
        qemu-user \
        gdb-multiarch \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if getent group "$GID" >/dev/null; then \
        EXISTING_GROUP=$(getent group "$GID" | cut -d: -f1); \
    else \
        groupadd -g "$GID" "$USERNAME"; \
        EXISTING_GROUP="$USERNAME"; \
    fi; \
    if id -u "$UID" >/dev/null 2>&1; then \
        EXISTING_USER=$(id -nu "$UID"); \
        usermod -g "$EXISTING_GROUP" "$EXISTING_USER"; \
        if [ "$EXISTING_USER" != "$USERNAME" ]; then \
            usermod -l "$USERNAME" -d "/home/$USERNAME" -m "$EXISTING_USER"; \
        fi; \
    else \
        useradd -m -u "$UID" -g "$EXISTING_GROUP" -s /bin/bash "$USERNAME"; \
    fi; \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PS1="[\u@\h \W]\\$ "' >> ~/.bashrc

RUN git clone https://gitlab.com/qemu-project/qemu.git /home/${USERNAME}/qemu-src && \
    cd /home/${USERNAME}/qemu-src && \
    git checkout stable-9.0


RUN cd /home/${USERNAME}/qemu-src && \
    ./configure \
        --target-list=riscv32-softmmu,riscv64-softmmu \
        --enable-debug \
        --prefix=/home/${USERNAME}/.local && \
    make -j"$(nproc)" && \
    make install


RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'cd ~/qemu-src' \
'./configure --target-list=riscv32-softmmu,riscv64-softmmu --enable-debug --prefix="$HOME/.local"' \
'make -j"$(nproc)"' \
'make install' \
> /home/${USERNAME}/rebuild-qemu.sh && chmod +x /home/${USERNAME}/rebuild-qemu.sh
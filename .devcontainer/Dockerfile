FROM ubuntu:20.04

# fix issues
ARG HOST_UID=1000
ARG HOST_GID=1000

ENV HOST_UID=${HOST_UID}
ENV HOST_GID=${HOST_GID}

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Vienna
RUN apt-get update

RUN apt-get install -y autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN apt-get install -y git wget libncurses5-dev vim cpio python3-venv python3-distutils gcc-riscv64-unknown-elf
RUN apt-get install gosu

RUN wget -q https://toolchains.bootlin.com/downloads/releases/toolchains/riscv64-lp64d/tarballs/riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2
RUN mkdir /opt/bootlin
RUN tar jxf riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2 -C /opt/bootlin

ENV CROSS_COMPILE=/opt/bootlin/riscv64-lp64d--glibc--stable-2021.11-1/bin/riscv64-buildroot-linux-gnu-
ENV ARCH=riscv

RUN useradd -u $HOST_UID -o -m user
RUN groupmod -g $HOST_GID user

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh

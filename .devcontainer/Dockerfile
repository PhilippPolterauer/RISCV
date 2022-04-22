FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Vienna
RUN apt-get update

RUN apt-get install -y autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN apt-get install -y git wget libncurses5-dev qemu-system-riscv64 vim cpio python3-venv python3-distutils gcc-riscv64-unknown-elf

RUN wget https://toolchains.bootlin.com/downloads/releases/toolchains/riscv64-lp64d/tarballs/riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2
RUN mkdir /opt/bootlin
RUN tar jxf riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2 -C /opt/bootlin

ENV CROSS_COMPILE=/opt/bootlin/riscv64-lp64d--glibc--stable-2021.11-1/bin/riscv64-buildroot-linux-gnu-
ENV ARCH=riscv

ENTRYPOINT /bin/bash



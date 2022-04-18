FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Vienna
RUN apt-get update

RUN apt-get install -y autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN apt-get install -y git wget ncurses

RUN wget https://toolchains.bootlin.com/downloads/releases/toolchains/riscv64-lp64d/tarballs/riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2
RUN mkdir /opt/bootlin
RUN tar jxf riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2 -C /opt/bootlin
RUN mkdir /opt/kernel
WORKDIR /opt/kernel
RUN git clone -b v5.11 --single-branch --depth 1 https://github.com/torvalds/linux
WORKDIR /opt/kernel/linux

ENV CROSS_COMPILE=/opt/bootlin/riscv64-lp64d--glibc--stable-2021.11-1/bin/riscv64-buildroot-linux-gnu-
ENV ARCH=riscv

# RUN git clone -b 2022.04.12 --recursive --single-branch --depth=1 https://github.com/riscv/riscv-gnu-toolchain
# WORKDIR /riscv-gnu-toolchain
# RUN mkdir /opt/riscv
# RUN ./configure --prefix=/opt/riscv
# RUN make linux

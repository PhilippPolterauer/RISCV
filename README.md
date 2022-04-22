# Simple RISCV Busybox example
This repository contains a Docker Container and a readme showing how to build your own linux kernel and start it with a busybox intramfs.

References:
- [riscv-docs](https://risc-v-getting-started-guide.readthedocs.io/en/latest/index.html)


## TLDR

0) On Windows start wsl2 and navigate to a wsl2 folder (for performance reasons)

1) clone the repository and open VSCODE from within wsl2 
```bash
# from a normal terminal start wsl
wsl
# change to a local folder (!important for performance)
cd
# clone repository
git clone https://github.com/PhilippPolterauer/RISCV.git
# OPEN it in vscode
cd RISCV && code .
```

2) start the docker 
    - either through VSCode (open inside devcontainer)
    - or manually
```bash
# build container with tag riscv
docker build .devcontainer/Dockerfile -t riscv
# run image
docker run riscv
```
3) run the main script
```bash
# Run all
./scripts/run_all.sh
```
4) copy files to host and start qemu with the kernel and initramfs
```bash
# on windows (the following commandos copy everything to the home folder)
#    inside terminal
wsl # start wsl2
cp ~/RISCV/build/linux/arch/riscv/boot/Image .
cp ~/RISCV/build/initramfs.cpio.gz .
# CTRL+D to close wsl2

# run qemu on pwershell or cmd
qemu-system-riscv64 -machine virt -kernel Image -initrd initramfs.cpio.gz -nographic -append "console=ttyS0"
```
```bash
# or on linux
cd ~/RISCV
qemu-system-riscv64 -kernel ./build/linux/arch/riscv/boot/Image -initrd ./build/initramfs.cpio.gz -nographic -append "console=ttyS0"
```

# Detailed Instructions
## Prequisites
- Install qemu from [here](https://www.qemu.org/download/)
- I suggest useing vscode and start the devcontainer

## Suggested Tools
- WSL2
- docker
- vscode

## Get Sources
we use linux kernel v5.17 and busybox 1.35.0

```bash
# prepare source folder
export SRC_FOLDER=/workspaces/RISCV/source
mkdir -p $SRC_FOLDER
cd $SRC_FOLDER

# if git is available
git clone https://github.com/torvalds/linux/ -b v5.17 --single-branch --depth 1
git clone https://git.busybox.net/busybox -b 1_35_0 --single-branch --depth 1

# or otherwise download tarballs
wget https://github.com/torvalds/linux/archive/refs/tags/v5.17.tar.gz 
wget https://git.busybox.net/busybox/snapshot/busybox-1_35_0.tar.bz2

# and unpack the files
tar -xvf v5.17.tar.gz 
tar -xvfj busybox-1_35_0.tar.bz2 
```

prepare build folder
```bash
export BUILD_FOLDER=/workspaces/RISCV/build
mkdir -p $BUILD_FOLDER/{busybox,linux,intitramfs}
```

## Building Linux with default configuration
```bash
cd /opt/kernel/linux/
mkdir -p $BUILD_FOLDER/linux
# configure make all default
make O=$BUILD_FOLDER/linux/ defconfig
# build linux 
make O=$BUILD_FOLDER/linux/ -j8
```

## Building Busybox with minimal configuration
```bash
mkdir -p $BUILD_FOLDER/busybox
cd $SRC_FOLDER/busybox
make O=$BUILD_FOLDER/busybox/ defconfig
```
configure static linking of busybox either manually using menuconfig 

```bash
make O=$BUILD_FOLDER/busybox/ menuconfig 
# check the build option under
# -> Settings
# --- Build Options
#   -> [*] Build static binary (no shared libs)   
```
or with the following command
```bash
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' $BUILD_FOLDER/busybox/.config
```
```bash
# enable static binary building
make O=$BUILD_FOLDER/busybox/ -j8
# this copies everything to _install folder 
make O=$BUILD_FOLDER/busybox/ install
```


## makeing an initramfs file containing the busybox files
```bash
# clean folder
rm -r $BUILD_FOLDER/initramfs/*
# start new
cd $BUILD_FOLDER/initramfs
# setup basic filesystem
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
# copy all of busybox installation files
cp -av $BUILD_FOLDER/busybox/_install/* .
# setup basic init executable
printf "#\!/bin/sh\n# exec /bin/sh" >> init
chmod +x init # make sure the init file is executable
# generate intramfs file
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $BUILD_FOLDER/initramfs.cpio.gz
```

## launch qemu with kernel and initramfs
use the following command from within the native (windows) terminal where qemu shall be installed
```
qemu-system-riscv64 -kernel .\build\linux\arch\riscv\boot\Image -initrd .\build\initramfs.cpio.gz -nographic -append "console=ttyS0"
```



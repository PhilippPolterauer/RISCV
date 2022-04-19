# Build scripts after launching the Docker


## Building Linux with minimal configuration
```bash
cd linux/
mkdir -p /workspaces/RISCV/build/linux
make O=/workspaces/RISCV/build/linux/ alldefconfig
make O=/workspaces/RISCV/build/linux/ nconfig
# select terminal
make O=/workspaces/RISCV/build/linux/ kvm_guest.config
make O=/workspaces/RISCV/build/linux/ -j8

```

## Building Busybox with minimal configuration

```bash
mkdir -p /workspaces/RISCV/build/busybox
cd /opt/kernel/busybox
make O=/workspaces/RISCV/build/busybox/ defconfig
make O=/workspaces/RISCV/build/busybox/ menuconfig
# select static library
make O=/workspaces/RISCV/build/busybox/ -j8
make O=/workspaces/RISCV/build/busybox/ install
```


## makeing an initramfs file
```bash
cd /workspaces/RISCV
mkdir initramfs
cd initramfs
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
# copy all of busybox
cp -av /workspaces/RISCV/build/busybox/_install/* .
# printf "#\!/bin/sh\n
# mount -t proc none /proc\n
# mount -t sysfs none /sys\n
# echo -e \"\\\nBoot took \$(cut -d' ' -f1 /proc/uptime) seconds\\\n\"\n
# exec /bin/sh" >> init

chmod +x init
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /workspaces/RISCV/build/initramfs-busybox.cpio.gz
```

## launch qemu with kernel and initramfs
qemu-system-riscv64 -kernel .\build\linux\arch\riscv\boot\Image -initrd .\build\initramfs-busybox.cpio.gz -nographic -append "console=ttyS0"
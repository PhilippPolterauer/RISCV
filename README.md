# Build scripts after launching the Docker


## Building Linux with minimal configuration
```bash
cd linux/
mkdir -p /workspaces/RISCV/build/linux
make O=/workspaces/RISCV/build/linux/ alldefconfig
make O=/workspaces/RISCV/build/linux/ nconfig
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
```
cd /workspaces/RISCV
mkdir initramfs

```
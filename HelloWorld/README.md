# build hello world for sifive_u
simple hello world riscv qemu example

```bash
make
```

run the kernel in qemu
```
qemu-system-riscv64 -nographic -machine sifive_u -bios none -kernel .\kernel\hello
```
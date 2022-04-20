# build hello world for sifive_u

```bash
make
```

run the kernel in qemu
```
qemu-system-riscv64 -nographic -machine sifive_u -bios none -kernel .\kernel\hello
```
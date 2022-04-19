hello: hello.o link.lds
	riscv32-unknown-elf-ld -T link.lds -o hello hello.o

hello.o: hello.s
	riscv32-unknown-elf-as -o hello.o hello.s

clean:
	rm hello hello.o
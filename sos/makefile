osmake:	kernel.asm kernel.c
	nasm -f elf32 kernel.asm -o kasm.o
	i586-elf-gcc -m32 -c kernel.c -o kc.o
	i586-elf-ld -m elf_i386 link.ld -o kernel.bin kasm.o kc.o

test: kernel.asm kernel.c
	nasm -f elf32 kernel.asm -o kasm.o
	i586-elf-gcc -m32 -c kernel.c -o kc.o -ffreestanding
	i586-elf-ld -m elf_i386 -T link.ld -o bin/kernel.bin kasm.o kc.o
	qemu-system-i386 -kernel bin/kernel.bin
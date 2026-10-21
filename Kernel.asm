bits 32 ;32 bit OS

section .text
	align 4 ;4 bytes
	dd 0x1BADB002 ;Magic Number
	dd 0x00
	dd -(0x1BADB002+0x00)

global start
	extern kmain ;Defined in C (Kernel.c)

start: ;starts executing with the linker
	cli ;clears the interrupts
	call kmain ;Call the main function for the kernel
	hlt ;pause the CPU from executing
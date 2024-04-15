.DEFAULT_GOAL=qemu

SRC=$(wildcard src/*.asm)
OBJ=$(patsubst src/%.asm,obj/%.o,${SRC})
BIN=$(patsubst src/%.asm,bin/%.bin,${SRC})

bochs: pongos.img
	bochs -q -f bochsrc

qemu: pongos.img
	qemu-system-i386 -device VGA -fda pongos.img

obj/%.o: src/%.asm src/defines.asm
	nasm -felf32 $< -o $@

pongos.img: ${OBJ} linker.ld
	i686-elf-gcc -g -T linker.ld -o $@ -ffreestanding -O2 -nostdlib ${OBJ}

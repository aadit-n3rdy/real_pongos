bits 16

section .mbr.text
global bootloader_start
extern _start
bootloader_start:
	xor ax, ax
	cli
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	sti

	mov ax, stack_top
	shr ax, 4
	mov ss, ax
	mov sp, stack_bottom - stack_top
	mov bp, stack_bottom - stack_top - 1

	mov [BOOT_DRIVE], dl

	mov ah, 0x00
	int 0x13

	mov bx, loading_msg
	call printString

	call printNewline

	mov bx, 0x8000
	mov ch, 0x00 	; Cylinder
	mov dh, 0		; Head
	mov cl, 0x02	; Cylinder (2 bits), Sector
	mov dl, [BOOT_DRIVE]
	mov ah, 0x02	; Function (read from disk)
	mov al, 0x08	; No. of sectors
	int 0x13

	cmp ah, 0x00
	jne error

	call _start

	jmp bootloader_hlt

error:
	mov bx, err_msg
	call printString
	call printNewline
	call printHex
	call printNewline
	jmp bootloader_hlt

bootloader_hlt:
	mov bx, halt_msg
	call printString
	.halt:
	hlt
	jmp .halt

printChar:
	; Print the character in al
	pusha
	mov bh, 0x00
	mov bl, 0x00
	mov ah, 0x0E
	int 0x10
	popa
	ret

printString:
	pusha
	.loop_start:
	mov al, [bx]
	cmp al, 0
	je .loop_end
	inc bx
	call printChar
	jmp .loop_start
	.loop_end:
	popa
	ret

printHex:
	pusha
	mov bx, ax
	mov al, bh
	and al, 0xf0
	shr al, 4
	call printHexChar
	mov al, bh
	and al, 0x0f
	call printHexChar
	mov al, bl
	and al, 0xf0
	shr al, 4
	call printHexChar
	mov al, bl
	and al, 0x0f
	call printHexChar
	popa
	ret

printHexChar:
	pusha
	cmp al, 0x0a
	jge .phc_alpha
.phc_digit:
	add al, '0'
	jmp .phc_print
.phc_alpha:
	add al, 'A' - 10
.phc_print:
	call printChar
	popa
	ret

printNewline:
	push bx
	mov bx, newline
	call printString
	pop bx
	ret

section .mbr.data
msg: db 'Hello World',0x0a,0x0d,0
halt_msg: db 'Halting from bootloader', 0x0a, 0x0d, 0
newline: db 0x0a, 0x0d, 0
loading_msg: db 'Loading sector 2 from disk', 0
err_msg: db 'ERROR while loading disk', 0
BOOT_DRIVE: db 0xff

section .bss
stack_top:
resb 512
stack_bottom:

section .mbr.sig
db 0x55
db 0xAA

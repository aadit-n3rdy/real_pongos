; org 0x8000
bits 16

%include "src/defines.asm"

extern drawPaddle
extern swapBuffers
extern initGraphics
extern clearScreen

section .text
global _start
_start:
	; Set video mode to 320x200 graphics
	mov ah, 0x00
	mov al, 0x13
	int 0x10

	call initGraphics

	mov ah, 0x00
	int 0x1A

	push dx

	.loop_start:

	mov ax, [paddle1]
	add ax, 5
	and ax, word 0x3f
	mov word [paddle1], ax
	push ax
	mov ax, 1
	push ax; right
	call drawPaddle
	add sp, 4

	mov ax, [paddle0]
	add ax, 1
	and ax, word 0x3f
	mov word [paddle0], ax
	push ax; pos
	mov ax, 0
	push ax; left
	call drawPaddle
	add sp, 4

	call swapBuffers

	call clearScreen

	.wait_start:
	mov ah, 0x00
	int 0x1A
	pop cx
	push cx
	add cx, 10
	cmp dx, cx
	jle .wait_start

	pop cx
	push dx

	jmp .loop_start

_khalt:
	hlt
	jmp _khalt

section .data
paddle0: dw 0
paddle1: dw 0

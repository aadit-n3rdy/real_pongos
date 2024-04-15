; org 0x8000
bits 16

%include "src/defines.asm"

extern drawPaddle
extern swapBuffers
extern initGraphics
extern clearScreen
extern drawBoundary
extern handleInput

extern player1_inp
extern player2_inp

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

	call handleInput

	mov byte al, [player1_inp]
	cmp al, MOVE_UP
	jne .no_up1
	sub word [paddle0], PADDLE_VELOCITY
	jmp .p1_done
	.no_up1:
	cmp al, MOVE_DOWN
	jne .p1_done
	add word [paddle0], PADDLE_VELOCITY

	.p1_done:
	mov byte al, [player2_inp]
	cmp al, MOVE_UP
	jne .no_up2
	sub word [paddle1], PADDLE_VELOCITY
	jmp .p2_done
	.no_up2:
	cmp al, MOVE_DOWN
	jne .p2_done
	add word [paddle1], PADDLE_VELOCITY

	.p2_done:

	mov ax, word [paddle1]
	push ax
	mov ax, 1
	push ax; right
	call drawPaddle
	add sp, 4

	mov ax, [paddle0]
	push ax; pos
	mov ax, 0
	push ax; left
	call drawPaddle
	add sp, 4

	call drawBoundary

	call swapBuffers

	call clearScreen

	;.wait_start:
	;mov ah, 0x00
	;int 0x1A
	;pop cx
	;push cx
	;add cx, 10
	;cmp dx, cx
	;jle .wait_start

	pop cx
	push dx

	jmp .loop_start

_khalt:
	hlt
	jmp _khalt

section .data
paddle0: dw 0
paddle1: dw 0

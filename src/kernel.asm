; org 0x8000
bits 16

%include "src/defines.asm"

extern drawPaddle
extern swapBuffers
extern initGraphics
extern clearScreen
extern drawBoundary
extern handleInput
extern initInput
extern drawBall
extern checkBallWall
extern fixRange
extern checkBallPaddles

extern player1_inp
extern player2_inp

section .text
global _start
align 4
_start:
	; Set video mode to 320x200 graphics
	mov ah, 0x00
	mov al, 0x13
	int 0x10


	mov dword [ballX], WIDTH/2
	mov dword [ballY], PADDLE_LENGTH*2

	mov dword [ballVX], 1
	mov dword [ballVY], 1

	call initGraphics

	call initInput

	mov ah, 0x00
	int 0x1A

	push dx

	.loop_start:

	mov byte al, [player1_inp]
	cmp al, MOVE_UP
	jne .no_up1
	sub word [paddle0], PADDLE_VELOCITY
	jmp .p0_check
	.no_up1:
	cmp al, MOVE_DOWN
	jne .p0_done
	add word [paddle0], PADDLE_VELOCITY

	.p0_check:

	push word [paddle0]
	push word HEIGHT-PADDLE_LENGTH
	call fixRange
	add sp, 4
	mov word [paddle0], ax

	.p0_done:

	mov byte al, [player2_inp]
	cmp al, MOVE_UP
	jne .no_up2
	sub word [paddle1], PADDLE_VELOCITY
	jmp .p1_check
	.no_up2:
	cmp al, MOVE_DOWN
	jne .p1_done
	add word [paddle1], PADDLE_VELOCITY

	.p1_check:

	push word [paddle1]
	push word HEIGHT-PADDLE_LENGTH
	call fixRange
	add sp, 4
	mov word [paddle1], ax
	.p1_done:

	call checkBallPaddles

	call checkBallWall

	cmp word [paddle1_done], 0
	jg _khalt

	cmp word [paddle0_done], 0
	jg _khalt
	
	mov ax, word [ballX]
	add ax, word [ballVX]
	mov word [ballX], ax

	mov ax, word [ballY]
	add ax, word [ballVY]
	mov word [ballY], ax

	mov ax, word [ballX]
	push ax
	mov ax, word [ballY]
	push ax
	call drawBall
	pop ax
	pop ax

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

	mov ah, 0x86
	mov cx, 0x00
	mov dx, 0x10
	int 0x15

	pop cx
	push dx

	jmp .loop_start

_khalt:
	hlt
	jmp _khalt

section .data
align 4
global paddle0
global paddle1
global paddle0_done
global paddle1_done
paddle0: 	dw 0
paddle1: 	dw 0
paddle0_done: dw 0
paddle1_done: dw 0

global ballX
global ballY
global ballVX
global ballVY
align 4
ballX:		dw 0
ballY: 		dw 0
ballVX:		dw 0
ballVY:		dw 0

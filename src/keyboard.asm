bits 16

%include "src/defines.asm"

section .text

global handleInput
handleInput:
	push bp
	mov bp, sp
	pusha

	mov byte [player1_inp], MOVE_NONE
	mov byte [player2_inp], MOVE_NONE

	mov al, 'A'
	out 0xE9, al

	mov ah, 0x01
	int 0x16

	jz .done

	mov ah, 0x00
	int 0x16

	out 0xE9, al
	xchg bx, bx

	cmp al, 'w'
	jne .elif_1
	mov byte [player1_inp], MOVE_UP
	jmp .done

	.elif_1:
	cmp al, 's'
	jne .elif_2
	mov byte [player1_inp], MOVE_DOWN
	jmp .done

	.elif_2:
	cmp al, 'i'
	jne .elif_3
	mov byte [player2_inp], MOVE_UP
	jmp .done

	.elif_3:
	cmp al, 'k'
	jne .done
	mov byte [player2_inp], MOVE_DOWN
	jmp .done

	.done:

	popa
	pop bp
	ret

section .data
global player1_inp
global player2_inp
player1_inp: db 0
player2_inp: db 0

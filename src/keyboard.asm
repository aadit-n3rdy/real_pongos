bits 16

%include "src/defines.asm"

%define W_PRESSED	0x11
%define W_RELEASED	0x91
%define S_PRESSED	0x1F
%define S_RELEASED	0x9F
%define I_PRESSED	0x17
%define I_RELEASED	0x97
%define K_PRESSED	0x25
%define K_RELEASED	0xA5

section .text

global initInput
align 4
initInput:
	push ax
	push bx

	mov dword [0x0024], kbintHandler

	pop ax
	pop bx
	ret

global kbintHandler
align 4
kbintHandler:

	pusha

	in byte al, 0x60

	cmp al, W_RELEASED
	je .clear_player1
	cmp al, S_RELEASED
	je .clear_player1

	cmp al, I_RELEASED
	je .clear_player2
	cmp al, K_RELEASED
	je .clear_player2

	jmp .noclear

	.clear_player1:
	mov byte [cs:player1_inp], MOVE_NONE
	jmp .done

	.clear_player2:
	mov byte [cs:player2_inp], MOVE_NONE
	jmp .done

	.noclear:

	cmp al, W_PRESSED
	jne .elif_1
	mov byte [cs:player1_inp], MOVE_UP
	jmp .done

	.elif_1:
	cmp al, S_PRESSED
	jne .elif_2
	mov byte [cs:player1_inp], MOVE_DOWN
	jmp .done

	.elif_2:
	cmp al, I_PRESSED
	jne .elif_3
	mov byte [cs:player2_inp], MOVE_UP
	jmp .done

	.elif_3:
	cmp al, K_PRESSED
	jne .done
	mov byte [cs:player2_inp], MOVE_DOWN

	.done:

	mov al, 0x20
	out 0x20, al

	popa
	iret





section .data
global player1_inp
global player2_inp
align 4
player1_inp: db 0
player2_inp: db 0

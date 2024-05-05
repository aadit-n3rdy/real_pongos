bits 16

%include "src/defines.asm"

extern ballX
extern ballY
extern ballVX
extern ballVY
extern paddle0
extern paddle1
extern paddle0_done
extern paddle1_done

section .text
global checkBallWall
align 4
checkBallWall:
	; no arguments, uses global ball variable, fixed position, fixes velocity
	push bp
	mov bp, sp
	pusha

	mov ax, word [ballX]
	mov bx, word [ballVX]

	shr ax, 2

	cmp ax, 0
	jg .x_0_done
	;mov word [ballX], 4
	;neg bx
	;mov word [ballVX], bx
	mov word [paddle0_done], 1
	jmp .x_done
	.x_0_done:

	cmp ax, WIDTH
	jl .x_done
	;mov word [ballX], (WIDTH-1)*4
	;neg bx
	;mov word [ballVX], bx
	mov word [paddle1_done], 1
	.x_done:

	mov ax, word [ballY]
	mov bx, word [ballVY]

	shr ax, 2

	cmp ax, 0
	jg .y_0_done
	mov word [ballY], 4
	neg bx
	mov word [ballVY], bx
	jmp .y_done
	.y_0_done:

	cmp ax, HEIGHT
	jl .y_done
	mov word [ballY], (HEIGHT-1)*4
	neg bx
	mov word [ballVY], bx
	.y_done:

	popa
	pop bp
	ret

global checkBallPaddles
align 4
checkBallPaddles:
	push bp
	mov bp, sp
	pusha

	mov ax, word [ballX]
	mov cx, word [ballY]
	shr ax, 2
	shr cx, 2

	cmp ax, PADDLE_WIDTH
	jg .no_paddle0
	sub cx, word [paddle0]
	cmp cx, 0
	jl .no_paddle0
	cmp cx, PADDLE_LENGTH
	jg .no_paddle0
	mov word [ballX], (PADDLE_WIDTH+1)*4
	mov bx, word [ballVX]
	neg bx
	mov word [ballVX], bx
	jmp .done

	.no_paddle0:

	mov cx, word [ballY]
	shr cx, 2

	xchg bx, bx
	mov bx, PADDLE_WIDTH
	neg bx
	add bx, WIDTH
	cmp ax, bx
	jl .no_paddle1
	sub cx, word [paddle1]
	cmp cx, 0
	jl .no_paddle1
	cmp cx, PADDLE_LENGTH
	jg .no_paddle1
	mov word [ballX], (WIDTH-PADDLE_WIDTH-1)*4
	mov bx, word [ballVX]
	neg bx
	mov word [ballVX], bx

	.no_paddle1:

	.done:

	popa
	pop bp
	ret


global fixRange
align 4
fixRange:
	push bp
	mov bp, sp
	push cx

	; params: val, range

	mov ax, word [ss:bp+4] ; range
	mov bx, word [ss:bp+6] ; val

	xor cx, cx

	cmp bx, 0
	jge .above_done
	mov bx, 0
	mov cx, 1
	jmp .below_done
	.above_done:

	cmp bx, ax
	jl .below_done
	mov bx, ax
	mov cx, 1
	.below_done:

	mov ax, bx
	mov bx, cx

	pop cx
	pop bp
	ret

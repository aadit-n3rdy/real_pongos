bits 16

%include "src/defines.asm"

section .data
cur_page: db 1

section .text

global initGraphics
align 4
initGraphics:
	mov ax, 0xA00
	mov es, ax
	mov ax, 0
	ret

global drawTest
align 4
drawTest:
	pusha
	mov bx, 0x0
	.loop_start:
	cmp bx, WIDTH*50
	jge .loop_end
	mov byte [es:bx], 0x0f
	add bx, WIDTH
	jmp .loop_start
	.loop_end:
	popa
	ret

global drawPaddle
align 4
drawPaddle:
	; arguments: position, L/R

	; stack (from top):
	; old bp <-bp
	; ret
	; 0: left, 1: right
	; pos

	push bp
	mov bp, sp

	pusha

	mov cx, [ss:bp+4] ;l/r
	mov dx, [ss:bp+6] ;pos

	cmp dx, HEIGHT
	jge .error

	cmp cx, 0
	jne .set_col_1
	.set_col_0:
	; USES PADDING
	mov cx, PADDING
	jmp .set_col_end
	.set_col_1:
	; USES WIDTH AND PADDING
	mov cx, WIDTH - PADDING - PADDLE_WIDTH
	.set_col_end:

	; Get starting address
	push dx
	mov ax, dx
	xor dx, dx
	mov bx, WIDTH
	imul bx
	mov bx, ax
	pop dx
	add bx, cx

	mov dx, PADDLE_LENGTH
	mov cx, PADDLE_WIDTH

	.dp_outer_start:
	cmp dx, 0
	je .dp_outer_end

	; outer body
	cmp bx, WIDTH*HEIGHT
	jb .fix_height_end
	sub bx, WIDTH*HEIGHT
	.fix_height_end:

	mov cx, PADDLE_WIDTH

	.dp_inner_start:
	cmp cx, 0
	jle .dp_inner_end

	; inner body
	mov byte [es:bx], 0x0f

	dec cx
	add bx, 1
	jmp .dp_inner_start
	.dp_inner_end:

	; outer body

	dec dx
	add bx, WIDTH - PADDLE_WIDTH
	jmp .dp_outer_start
	.dp_outer_end:

	popa

	pop bp
	ret

	.error:
	popa 
	pop bp
	ret

global clearScreen
align 4
clearScreen:
	push bx
	mov bx, WIDTH*HEIGHT-1
	.cs_start:
	cmp bx, 0
	je .cs_end

	mov dx, 0
	mov ax, bx
	mov cx, word WIDTH
	idiv word cx
	cmp dx, BORDER
	jl .border
	cmp dx, WIDTH-BORDER
	jge .border
	cmp ax, BORDER
	jl .border
	cmp ax, HEIGHT-BORDER
	jge .border
	jmp .no_border

	.border:

	mov byte [es:bx], 0x0f
	jmp .bend

	.no_border:

	mov byte [es:bx], 0x00

	.bend:

	dec bx
	jmp .cs_start
	.cs_end:

	mov byte [es:0], 0x00

	pop bx
	ret

global drawBoundary
align 4
drawBoundary:
	; no inp params
	push bp
	mov bp, sp
	pusha

	mov bx, WIDTH/2 - BOUNDARY_WIDTH/2

	.outer_begin:

	mov ax, BOUNDARY_GAP

	.middle_begin:

	push ax

	mov ax, BOUNDARY_WIDTH

	.inner_begin:

	mov byte [es:bx], 0x0f
	inc bx

	dec ax
	cmp ax, 0
	ja .inner_begin
	.inner_end:

	pop ax

	add bx, WIDTH-BOUNDARY_WIDTH

	dec ax
	cmp ax, 0
	ja .middle_begin
	.middle_end:

	add bx, WIDTH*(BOUNDARY_GAP+1)

	cmp bx, WIDTH*HEIGHT
	jb .outer_begin
	.outer_end:

	pop bp
	popa
	ret

global swapBuffers
align 4
swapBuffers:
	push bp
	mov bp, sp
	pusha

	mov ax, 0xA000
	mov fs, ax

	mov bx, 320*200-1
	.loop_start:
	cmp bx, 0
	je .loop_end

	mov cl, byte [es:bx]
	mov byte [fs:bx], cl

	dec bx
	jmp .loop_start
	.loop_end:

	popa
	pop bp
	ret

global drawBall
align 4
drawBall:
	push bp
	mov bp, sp
	pusha

	mov ax, [ss:bp+4] ;Y
	mov bx, [ss:bp+6] ;X

	add bx, 1

	shr ax, 2
	shr bx, 2

	mov dx, 0x00
	mov si, WIDTH 
	imul si
	add bx, ax

	mov byte [es:bx], 0x0f
	dec bx
	mov byte [es:bx], 0x0f
	add bx, 2
	mov byte [es:bx], 0x0f
	sub bx, WIDTH
	mov byte [es:bx], 0x0f
	dec bx
	mov byte [es:bx], 0x0f
	dec bx
	mov byte [es:bx], 0x0f
	add bx, WIDTH*2
	mov byte [es:bx], 0x0f
	inc bx
	mov byte [es:bx], 0x0f
	inc bx
	mov byte [es:bx], 0x0f

	popa
	pop bp
	ret

delay:
	push ax
	mov ax, 0x00
	.start:
	cmp ax, 0xffff
	je .exit
	
	pusha
	popa
	pusha
	popa

	inc ax
	jmp .start
	.exit:
	pop ax
	ret

getOther:
	shr al, 1
	xor al, 1
	shl al, 1
	ret

section .framebuf
resb 320*200

segment code
..start:
	mov 		ax,data
	mov 		ds,ax
	mov 		ax,stack
	mov 		ss,ax
	mov 		sp,stacktop

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
	mov  		ah,0Fh
	int  		10h
	mov  		[modo_anterior],al   

; alterar modo de video para gr�fico 640x480 16 cores
	mov     	al,12h
	mov     	ah,0
	int     	10h

main:
	call printa_layout

	;modo cursor
	mov  ax, 1h
    int 33h


mouse:
	mov  ax, 5h
    mov  bx, 0h
	int  33h
	mov  [mouseClick],bx ;clicado ou nao
    mov  [mouseX],cx ;coordenada x
    mov  [mouseY],dx ;coordenada y

	cmp  word[mouseClick], 1  	;checa se o mouse foi clicado
	jne  mouse

	cmp  word[mouseY], 95		;checa se esta na area clicavel y<120
	ja   mouse

	cmp  word[mouseX], 80		;checa se é o botão Abrir
	jbe  func_botao_abrir

	cmp  word[mouseX], 140		;checa se é o botão Sair
	jbe  func_botao_sair

	cmp  word[mouseX], 300		;checa se é o botão passa-baixa
	jbe  func_botao_passa_baixa

	cmp  word[mouseX], 460		;checa se é o botão passa-alta
	jbe  func_botao_passa_alta

	jmp func_botao_gradiente

func_botao_sair:
	call printa_layout
	mov	 byte[cor], amarelo
	call printa_sair

	call delay

	mov  ah,0   			; set video mode
	mov  al,[modo_anterior]   	; modo anterior
	int  10h
	mov  ax,4c00h
	int  21h

func_botao_abrir:
	call printa_layout
	mov	 byte[cor], amarelo
	call printa_abrir

	call delay

	mov  ah,0   			; set video mode
	mov  al,[modo_anterior]   	; modo anterior
	int  10h
	mov  ax,4c00h
	int  21h

func_botao_passa_baixa:
	call printa_layout
	mov	 byte[cor], amarelo
	call printa_passa_baixa

	call delay

	mov  ah,0   			; set video mode
	mov  al,[modo_anterior]   	; modo anterior
	int  10h
	mov  ax,4c00h
	int  21h

func_botao_passa_alta:
	call printa_layout
	mov	 byte[cor], amarelo
	call printa_passa_alta

	call delay

	mov  ah,0   			; set video mode
	mov  al,[modo_anterior]   	; modo anterior
	int  10h
	mov  ax,4c00h
	int  21h

func_botao_gradiente:
	call printa_layout
	mov	 byte[cor], amarelo
	call printa_gradiente

	call delay

	mov  ah,0   			; set video mode
	mov  al,[modo_anterior]   	; modo anterior
	int  10h
	mov  ax,4c00h
	int  21h


printa_layout:
;---------LINHAS---------
	;esquerda
	mov		byte[cor],branco_intenso	
	mov		ax,0
	push		ax
	mov		ax,10
	push		ax
	mov		ax,0
	push		ax
	mov		ax,460
	push		ax
	call		line

	;cima
	mov		byte[cor],branco_intenso	
	mov		ax,0
	push		ax
	mov		ax,460
	push		ax
	mov		ax,620
	push		ax
	mov		ax,460
	push		ax
	call		line

	;direita
	mov		byte[cor],branco_intenso	
	mov		ax,620
	push		ax
	mov		ax,460
	push		ax
	mov		ax,620
	push		ax
	mov		ax,10
	push		ax
	call		line

	;baixo
	mov		byte[cor],branco_intenso	
	mov		ax,0
	push		ax
	mov		ax,10
	push		ax
	mov		ax,620
	push		ax
	mov		ax,10
	push		ax
	call		line

;linha separadora baixo	
	mov		ax,0
	push		ax
	mov		ax,85
	push		ax
	mov		ax,620
	push		ax
	mov		ax,85
	push		ax
	call		line

;linha separadora cima	
	mov		ax,0
	push		ax
	mov		ax,385
	push		ax
	mov		ax,620
	push		ax
	mov		ax,385
	push		ax
	call		line

;linha separadora meio	
	mov		ax,300
	push		ax
	mov		ax,85
	push		ax
	mov		ax,300
	push		ax
	mov		ax,460
	push		ax
	call		line

;linha separadora abrir_sair	
	mov		ax,80
	push		ax
	mov		ax,385
	push		ax
	mov		ax,80
	push		ax
	mov		ax,460
	push		ax
	call		line

;linha separadora sair_baixa	
	mov		ax,140
	push		ax
	mov		ax,385
	push		ax
	mov		ax,140
	push		ax
	mov		ax,460
	push		ax
	call		line

;linha separadora alta_gradiente	
	mov		ax,460
	push		ax
	mov		ax,385
	push		ax
	mov		ax,460
	push		ax
	mov		ax,460
	push		ax
	call		line

;-----------------quadrado nome matricula
	;esquerda
	mov		byte[cor],branco_intenso	
	mov		ax,10
	push		ax
	mov		ax,18
	push		ax
	mov		ax,10
	push		ax
	mov		ax,78
	push		ax
	call		line

	;cima
	mov		byte[cor],branco_intenso	
	mov		ax,10
	push		ax
	mov		ax,78
	push		ax
	mov		ax,610
	push		ax
	mov		ax,78
	push		ax
	call		line

	;direita
	mov		byte[cor],branco_intenso	
	mov		ax,610
	push		ax
	mov		ax,78
	push		ax
	mov		ax,610
	push		ax
	mov		ax,18
	push		ax
	call		line

	;baixo
	mov		byte[cor],branco_intenso	
	mov		ax,10
	push		ax
	mov		ax,18
	push		ax
	mov		ax,610
	push		ax
	mov		ax,18
	push		ax
	call		line


	;PRINTA AS MENSAGENS
	call printa_nome_matricula
	call printa_abrir
	call printa_sair
	call printa_passa_baixa
	call printa_passa_alta
	call printa_gradiente

	ret

;--------------MENSAGENS--------------
printa_nome_matricula:
	mov 	cx,43 ;qtd caracteres
	mov		bx,0
	mov		dh,27 ;linha
	mov		dl,15 ;coluna

l1:
	call	cursor
	mov     al,[bx+mensagem_nome]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l1
	ret

printa_abrir:
	mov 	cx,5 ;qtd caracteres
	mov		bx,0
	mov		dh,3 ;linha
	mov		dl,2 ;coluna

l2:
	call	cursor
	mov     al,[bx+mensagem_abrir]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l2
	ret

printa_sair:
	mov 	cx,4 ;qtd caracteres
	mov		bx,0
	mov		dh,3 ;linha
	mov		dl,12 ;coluna

l3:
	call	cursor
	mov     al,[bx+mensagem_sair]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l3
	ret

printa_passa_baixa:
	mov 	cx,12 ;qtd caracteres
	mov		bx,0
	mov		dh,3 ;linha
	mov		dl,21 ;coluna

l4:
	call	cursor
	mov     al,[bx+mensagem_passa_baixa]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l4
	ret

printa_passa_alta:
	mov 	cx,11 ;qtd caracteres
	mov		bx,0
	mov		dh,3 ;linha
	mov		dl,42 ;coluna

l5:
	call	cursor
	mov     al,[bx+mensagem_passa_alta]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l5
	ret

printa_gradiente:
	mov 	cx,9 ;qtd caracteres
	mov		bx,0
	mov		dh,3 ;linha
	mov		dl,63 ;coluna

l6:
	call	cursor
	mov     al,[bx+mensagem_gradiente]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	loop    l6
	ret
;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
	mov     	ah,2
	mov     	bh,0
	int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	push		bp
		mov     	ah,9
		mov     	bh,0
		mov     	cx,1
	mov     	bl,[cor]
		int     	10h
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	ret
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
	push		bp
	mov		bp,sp
	pushf
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	mov     	ah,0ch
	mov     	al,[cor]
	mov     	bh,0
	mov     	dx,479
	sub		dx,[bp+4]
	mov     	cx,[bp+6]
	int     	10h
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		4
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
	push		bp
	mov		bp,sp
	pushf                        ;coloca os flags na pilha
	push 		ax
	push 		bx
	push		cx
	push		dx
	push		si
	push		di
	mov		ax,[bp+10]   ; resgata os valores das coordenadas
	mov		bx,[bp+8]    ; resgata os valores das coordenadas
	mov		cx,[bp+6]    ; resgata os valores das coordenadas
	mov		dx,[bp+4]    ; resgata os valores das coordenadas
	cmp		ax,cx
	je		line2
	jb		line1
	xchg		ax,cx
	xchg		bx,dx
	jmp		line1
line2:		; deltax=0
	cmp		bx,dx  ;subtrai dx de bx
	jb		line3
	xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
	push		ax
	push		bx
	call 		plot_xy
	cmp		bx,dx
	jne		line31
	jmp		fim_line
line31:		inc		bx
	jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
; cx > ax
	push		cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push		dx
	sub		dx,bx
	ja		line32
	neg		dx
line32:		
	mov		[deltay],dx
	pop		dx

	push		ax
	mov		ax,[deltax]
	cmp		ax,[deltay]
	pop		ax
	jb		line5

; cx > ax e deltax>deltay
	push		cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push		dx
	sub		dx,bx
	mov		[deltay],dx
	pop		dx

	mov		si,ax
line4:
	push		ax
	push		dx
	push		si
	sub		si,ax	;(x-x1)
	mov		ax,[deltay]
	imul		si
	mov		si,[deltax]		;arredondar
	shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
	cmp		dx,0
	jl		ar1
	add		ax,si
	adc		dx,0
	jmp		arc1
ar1:		sub		ax,si
	sbb		dx,0
arc1:
	idiv		word [deltax]
	add		ax,bx
	pop		si
	push		si
	push		ax
	call		plot_xy
	pop		dx
	pop		ax
	cmp		si,cx
	je		fim_line
	inc		si
	jmp		line4

line5:		cmp		bx,dx
	jb 		line7
	xchg		ax,cx
	xchg		bx,dx
line7:
	push		cx
	sub		cx,ax
	mov		[deltax],cx
	pop		cx
	push		dx
	sub		dx,bx
	mov		[deltay],dx
	pop		dx



	mov		si,bx
line6:
	push		dx
	push		si
	push		ax
	sub		si,bx	;(y-y1)
	mov		ax,[deltax]
	imul		si
	mov		si,[deltay]		;arredondar
	shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
	cmp		dx,0
	jl		ar2
	add		ax,si
	adc		dx,0
	jmp		arc2
ar2:		sub		ax,si
	sbb		dx,0
arc2:
	idiv		word [deltay]
	mov		di,ax
	pop		ax
	add		di,ax
	pop		si
	push		di
	push		si
	call		plot_xy
	pop		dx
	cmp		si,dx
	je		fim_line
	inc		si
	jmp		line6

fim_line:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		8
;*******************************************************************

delay:
		push	cx
        mov 	cx, 800		; Carrega o valor 3 no registrador cx (contador para loop)
del2:
        push 	cx			; Coloca cx na pilha para usa-lo em outro loop
        mov 	cx, 0		; Zera cx
del1:
        loop 	del1		; No loop del1, cx eh decrementado seguidamente ate que volte a ser zero
        pop 	cx			; Recupera cx da pilha
        loop 	del2		; No loop del2, cx eh decrementado seguidamente ate que seja zero
		pop		cx
        ret

segment data

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0	
mensagem_nome    	db  		'Humberto Giuri, Sistema Embarcados - 2022/1' ; 43 caracteres
mensagem_abrir    	db  		'Abrir' ; 5 caracteres
mensagem_sair    	db  		'Sair' ; 4 caracteres
mensagem_passa_baixa   	db  	'Passa-Baixas' ; 12 caracteres
mensagem_passa_alta    db  		'Passa_Altas' ; 11 caracteres
mensagem_gradiente    	db  	'Gradiente' ; 9 caracteres

mouseX 		dw 		0
mouseY 		dw 		0
mouseClick	dw 		0
;*************************************************************************
segment stack stack
		resb 		512
stacktop:


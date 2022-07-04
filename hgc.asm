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

    cmp  word[mouseY], 90		;checa se esta na area clicavel y<100
    ja   mouse

    cmp  word[mouseX], 86		;checa se é o botão Abrir
    jbe  func_botao_abrir

    cmp  word[mouseX], 131		;checa se é o botão Sair
    jbe  func_botao_sair

    cmp  word[mouseX], 300		;checa se é o botão passa-baixa
    jbe  func_botao_passa_baixa

    cmp  word[mouseX], 470		;checa se é o botão passa-alta
    jbe  func_botao_sair

    jmp func_botao_sair

func_botao_abrir:
    call printa_layout
    mov	 byte[cor], amarelo
    call printa_abrir

    call open_file

    mov word[i], 0
    mov word[j], 388
    
    call plota_image_abrir
    call close_file

    jmp mouse

error_opening:
    mov byte[cor], vermelho
    call printa_abrir

    jmp mouse

func_botao_sair:
    call printa_layout
    mov	 byte[cor], amarelo
    call printa_sair

    mov  ah,0   			; set video mode
    mov  al,[modo_anterior]   	; modo anterior
    int  10h
    mov  ax,4c00h
    int  21h
    
    jmp mouse

func_botao_passa_baixa:
    call printa_layout
    mov	 byte[cor], amarelo
    call printa_passa_baixa

    call open_file
    call plota_passa_baixa
    call close_file
    
    jmp mouse

plota_image_abrir:
    pusha
    call reseta_buffer
    inc word[contador]

    read_one_value:
        mov ax, 0
        mov dx, 0
        mov cx, 0
        mov bx, 0

        format_one_char:
            call read_one_char
            mov dl, byte[current_char]

            cmp dl, ' '
            je end_valor ; achou espaco

            sub dl, '0' ; transforma pro numero
            mov bl, 10
            mul bl		; mult al por 10
            add al, dl

            loop format_one_char

    end_valor: ;achamos um espaço
        mov byte[intensity], al
        call plot_pixel

        inc word[i] ;joga pro próximo pixel da direita
        cmp word[i], 300  ;verifica se completou a linha
        jne read_one_value

        ;completou a linha
        mov word[i], 0
        
        dec word[j]
        cmp word[j], 88
        je end_image ; completou a imagem
        jne read_one_value ; so completou a linha
        
    end_image: ;todos os numeros foram lidos
        mov word[j], 0
        popa
        ret

    verify_buffer:
        cmp word[contador], buffer_size
        jge reseta_buffer

        ret

    reseta_buffer:
        pusha
        mov word[contador], 0
        mov ah, 3fh
        mov bx, [file_handler]
        mov cx, buffer_size
        mov dx, buffer
        int 21h
        popa
        ret


read_one_char:
    pusha
    mov ax, 0
    call verify_buffer
            
    mov bx, word[contador]
    mov al, byte[buffer + bx]
    mov byte[current_char], al
    inc word[contador]
    
    popa
    ret

plota_passa_baixa:
    pusha
    mov word[j], 388

    call reseta_buffer
    inc word[contador]

    aux:
        call read_line
        call printa_linha_aux
        
        dec word[j]
        cmp word[j], 88
        jne aux

    mov word[j], 0
    popa
    ret


read_line: ;le 300 numeros do arquivo
    pusha
    mov word[current_col], 0
    
    loop_read_line:
        ;limpando registradores
        mov ax, 0
        mov bx, 0
        mov cx, 0
        mov dx, 0

        one_value_baixa:
            call read_one_char
            mov dl, byte[current_char]

            cmp dl, ' '
            je put_value

            sub dl, '0'
            mov cl, 10
            mul cl
            add al, dl

            loop one_value_baixa

        put_value:
            mov bx, word[current_col]
            mov byte[linha_aux + bx], al
            
            inc word[current_col]
            
            cmp word[current_col], 300
            jne loop_read_line

    mov word[pos_line], 0
    popa
    ret

printa_linha_aux:
    pusha
    mov word[i], 301
    mov word[pos_line], 0

    loop_printa_aux:
        mov ax, 0
        mov bx, 0
        mov dx, 0

        mov bx, word[pos_line]
        mov al, byte[linha_aux + bx]
        mov byte[intensity], al

        call plot_pixel
        inc word[i]
        inc word[pos_line]

        cmp word[pos_line], 300
        jne loop_printa_aux

    mov word[pos_line], 0
    popa
    ret

one_step_baixa:
    pusha
    mov cx, 300
    mov word[current_col], 1

    main_loop:
        mov ax, 0
        mov dx, 0
        mov word[i], 301

        mov bx, word[current_col]
        inc word[current_col]

        mov al, byte[linha_1 + bx]
        mov dl, byte[linha_1 + bx - 1]
        add ax, dx
        
        mov dl, byte[linha_1 + bx + 1]
        add ax, dx

        mov dl, byte[linha_2 + bx]
        add ax, dx

        mov dl, byte[linha_2 + bx - 1]
        add ax, dx
        
        mov dl, byte[linha_2 + bx + 1]
        add ax, dx

        mov dl, byte[linha_3 + bx]
        add ax, dx

        mov dl, byte[linha_3 + bx - 1]
        add ax, dx
        
        mov dl, byte[linha_3 + bx + 1]
        add ax, dx

        mov bl, 9
        div bl ; temos o resultado da convolucao em al pra um pixel

        call plot_pixel
        dec word[j]
        loop main_loop

    popa
    ret
    
plot_pixel: ; prepara a plotagem de um pixel para a funcao de passa baixa
    pusha
    mov ax, 0
    mov bx, 0

    mov al, byte[intensity]
    mov bl, 16 ; apenas 16 tons de cor
    div bl
    mov byte[cor], al
    
    mov bx, word[i] ;coordenada x
    push bx
    mov bx, word[j] ;coordenada y
    push bx
    
    call plot_xy ;printa o pixel
    popa
    ret


change_aux_line1: ; copia uma linha para outra
    push bx
    push cx
    push dx

    mov cx, 300
    mov bx, 0

    change_pos_1:
        mov dl, byte[linha_aux + bx]
        mov byte[linha_1 + bx + 1], dl
        inc bx
        loop change_pos_1
    
    pop dx
    pop cx
    pop bx
    ret

change_aux_line2:
    pusha

    mov cx, 300
    mov bx, 0

    change_pos_2:
        mov dl, byte[linha_aux + bx]
        mov byte[linha_2 + bx + 1], dl
        inc bx
        loop change_pos_2
    
    popa
    ret

change_aux_line3:
    pusha

    mov cx, 300
    mov bx, 0

    change_pos_3:
        mov dl, byte[linha_aux + bx]
        mov byte[linha_3 + bx + 1], dl
        inc bx
        loop change_pos_3
    
    popa
    ret

change_line3_line2:
    push bx
    push cx
    push dx

    mov cx, 302
    mov bx, 0

    change_pos_4:
        mov dl, byte[linha_3 + bx]
        mov byte[linha_2 + bx], dl
        inc bx
        loop change_pos_4
    
    pop dx
    pop cx
    pop bx
    ret

change_line2_line1:
    push bx
    push cx
    push dx

    mov cx, 302
    mov bx, 0

    change_pos_5:
        mov dl, byte[linha_2 + bx]
        mov byte[linha_1 + bx], dl
        inc bx
        loop change_pos_5
    
    pop dx
    pop cx
    pop bx
    ret

zera_line1:
    pusha

    mov cx, 302
    mov bx, 0

    change_pos_6:
        mov byte[linha_1 + bx], 0
        inc bx
        loop change_pos_6
    
    popa
    ret

change_zera_line3:
    push bx
    push cx
    push dx

    mov cx, 302
    mov bx, 0

    change_pos_7:
        mov byte[linha_1 + bx], 0
        inc bx
        loop change_pos_7
    
    pop dx
    pop cx
    pop bx
    ret

zera_line_aux:
    pusha

    mov cx, 300
    mov bx, 0

    change_pos_8:
        mov byte[linha_aux + bx], 0
        inc bx
        loop change_pos_8
    
    popa
    ret


open_file:
    pusha
    mov ax, 3d00h 		; abre arquivo em read only
    mov dx, filename	; nome do arquivo
    int 21h
    mov [file_handler], ax ;atualiza o buffer
    popa
    ret

close_file:
    pusha
    ;fecha o arquivo
    mov ah, 3eh
    mov bx, [file_handler]
    int 21h
    popa
    ret

printa_layout:
;---------LINHAS---------
    ;esquerda
    mov		byte[cor],branco_intenso	
    mov		ax,0
    push		ax
    mov		ax,0
    push		ax
    mov		ax,0
    push		ax
    mov		ax,479
    push		ax
    call		line

    ;cima
    mov		byte[cor],branco_intenso	
    mov		ax,0
    push		ax
    mov		ax,479
    push		ax
    mov		ax,639
    push		ax
    mov		ax,479
    push		ax
    call		line

    ;direita
    mov		byte[cor],branco_intenso	
    mov		ax,639
    push		ax
    mov		ax,479
    push		ax
    mov		ax,639
    push		ax
    mov		ax,0
    push		ax
    call		line

    ;baixo
    mov		byte[cor],branco_intenso	
    mov		ax,0
    push		ax
    mov		ax,0
    push		ax
    mov		ax,639
    push		ax
    mov		ax,0
    push		ax
    call		line

;linha separadora baixo	
    mov		ax,0
    push		ax
    mov		ax,89
    push		ax
    mov		ax,639
    push		ax
    mov		ax,89
    push		ax
    call		line

;linha separadora cima	
    mov		ax,0
    push		ax
    mov		ax,389
    push		ax
    mov		ax,639
    push		ax
    mov		ax,389
    push		ax
    call		line

;linha separadora meio	
    mov		ax,300
    push		ax
    mov		ax,89
    push		ax
    mov		ax,300
    push		ax
    mov		ax,479
    push		ax
    call		line

;linha separadora abrir_sair	
    mov		ax,86
    push		ax
    mov		ax,389
    push		ax
    mov		ax,86
    push		ax
    mov		ax,479
    push		ax
    call		line

;linha separadora sair_baixa	
    mov		ax,131
    push		ax
    mov		ax,389
    push		ax
    mov		ax,131
    push		ax
    mov		ax,479
    push		ax
    call		line

;linha separadora alta_gradiente	
    mov		ax,470
    push		ax
    mov		ax,389
    push		ax
    mov		ax,470
    push		ax
    mov		ax,479
    push		ax
    call		line

;-----------------quadrado nome matricula
    ;esquerda
    mov		byte[cor],branco_intenso	
    mov		ax,10
    push		ax
    mov		ax,5
    push		ax
    mov		ax,10
    push		ax
    mov		ax,84
    push		ax
    call		line

    ;cima
    mov		byte[cor],branco_intenso	
    mov		ax,10
    push		ax
    mov		ax,84
    push		ax
    mov		ax,629
    push		ax
    mov		ax,84
    push		ax
    call		line

    ;direita
    mov		byte[cor],branco_intenso	
    mov		ax,629
    push		ax
    mov		ax,84
    push		ax
    mov		ax,629
    push		ax
    mov		ax,5
    push		ax
    call		line

    ;baixo
    mov		byte[cor],branco_intenso	
    mov		ax,10
    push		ax
    mov		ax,5
    push		ax
    mov		ax,629
    push		ax
    mov		ax,5
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
    mov 	cx,45 ;qtd caracteres
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
    mov		dh,2 ;linha
    mov		dl,3 ;coluna

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
    mov		dh,2 ;linha
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
    mov		dh,2 ;linha
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
    mov		dh,2 ;linha
    mov		dl,43 ;coluna

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
    mov		dh,2 ;linha
    mov		dl,64 ;coluna

l6:
    call	cursor
    mov     al,[bx+mensagem_gradiente]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    l6
    ret

printa_erro:
    mov 	cx,4 ;qtd caracteres
    mov		bx,0
    mov		dh,150 ;linha
    mov		dl,60 ;coluna

l7:
    call	cursor
    mov     al,[bx+mensagem_erro]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    l7
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
i	dw	0
j	dw	0
deltay		dw		0
deltax		dw		0
contador	dw		0
pos_line	dw		0
current_line	dw	0
current_col		dw	0

current_char    db  0
intensity       db  0

linha_1: 	times 	302		resb	0
linha_2: 	times 	302		resb	0
linha_3: 	times 	302		resb	0
linha_aux: 	times	300		resb	0

buffer_size equ		1200
buffer 		resb 	buffer_size
filename 	db		'imagens/entrada.txt'
file_handler		dw		0

mensagem_nome    	db  		'Humberto Giuri, Sistema Embarcados I - 2022/1' ; 45 caracteres
mensagem_abrir    	db  		'Abrir' ; 5 caracteres
mensagem_sair    	db  		'Sair' ; 4 caracteres
mensagem_passa_baixa   	db  	'Passa-Baixas' ; 12 caracteres
mensagem_passa_alta    db  		'Passa-Altas' ; 11 caracteres
mensagem_gradiente    	db  	'Gradiente' ; 9 caracteres
mensagem_erro			db		'Erro' ; 4 caracteres

mouseX 		dw 		0
mouseY 		dw 		0
mouseClick	dw 		0
;*************************************************************************
segment stack stack
        resb 		512
stacktop:

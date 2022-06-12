;20l-1210 Haleema Jamil
;20L-1085 Zobia Hussain

[org 0x0100]

	jmp start

endgame: db 'END GAME'
score: db 'SCORE: '
time:	db 'TIME: 00:'
scor: dw 0 
ran: db 0
timer: db 120
popbit: db 0
oldisr: dd 0
tickcount: dw 0
seconds: dw 120

printsky: 	
			push es
			push ax
			push di
			
			mov ax, 0xb800
			mov es, ax
			mov di, 0

nextscreenloc:  
			mov word [es:di], 0x3000
			add di, 2
			cmp di, 4000
			jne nextscreenloc
			
			pop di
			pop ax
			pop es
			
			ret	
		
randomnumber: ; generate a random number using the system time
			push cx
			push dx
			push ax
			rdtsc ;getting a random number in ax dx
			xor dx,dx ;making dx 0 
			mov cx,27 
			div cx ;dividing by 6 to get numbers from 0-26
			mov byte [ran],dl ;moving the random number in variable 
			pop ax
			pop dx
			pop cx
			ret
		
keypress:
			mov ah,06h ; keyboard input 
			mov dl,0FFh ; don't wait for input 
			int 21h
end:
			ret
		
printnum: 
			push bp 
			mov bp, sp 
			push es 
			push ax 
			push bx 
			push cx 
			push dx 
			push di 
			mov ax, 0xb800 
			mov es, ax ; point es to video base 
			mov ax, [bp+4] ; load number in ax 
			mov bx, 10 ; use base 10 for division 
			mov cx, 0 ; initialize count of digits 
		
nextdigit: 
			mov dx, 0 ; zero upper half of dividend 
			div bx ; divide by 10 
			add dl, 0x30 ; convert digit into ascii value 
			push dx ; save ascii value on stack 
			inc cx ; increment count of values 
			cmp ax, 0 ; is the quotient zero 
			jnz nextdigit ; if no divide it again 
			mov di, [bp+6] ; point di to top left column 
			
nextpos: 
			pop dx ; remove a digit from the stack 
			mov dh, 0x07 ; use normal attribute 
			mov [es:di], dx ; print char on screen 
			add di, 2 ; move to next screen location 
				loop nextpos ; repeat for all digits on stack
			pop di 
			pop dx 
			pop cx 
			pop bx 
			pop ax 
			pop es 
			pop bp 
			ret 4
		
printstr: 	
			push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov di, [bp+8] ; point di to top left column
			mov si, [bp+6] ; point si to string
			mov cx, [bp+4] ; load length of string in cx
			mov ah, 0x71 ; normal attribute fixed in al

nextchar: 	
			mov al, [si] ; load next char of string
			mov [es:di], ax ; show this char on screen
			add di, 2 ; move to next screen location
			add si, 1 ; move to next char in string
			loop nextchar ; repeat the operation cx times
			
			pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 6

printendgame:
			push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di

			mov di,1630  ; push di position
			push di

			mov ax, endgame
			push ax ; push address of str

			push word 8 ;push size of str
			call printstr

			pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 
		
printscore:	
			push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di

			mov di,170  ; push di position
			push di

			mov ax, score
			push ax ; push address of str

			push word 8 ;push size of str
			call printstr
			
			push word 180
			push word[scor]
			call printnum ; print tick count

			pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 

printtime:	
			push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di

			mov di,300  ;push di position
			push di

			mov ax, time
			push ax ;push address of str

			push word 6 ;push size of str
			call printstr

			pop di
			pop si
			pop cx
			pop ax
			pop es
			pop bp
			ret 
		
printShape:
			push bp
			mov bp, sp
			
			sub sp, 4           ;creating two output space
			
			pusha
					
			mov ax, 0xb800
			mov es, ax

			mov ax, [bp + 6]	;top in ax
			mov bx, 160
			mul bx
			mov [bp - 2], ax	;top in [bp - 2]   ;top starting position on screen
			
			mov ax, [bp + 4]	;left in ax
			shl ax, 1
			mov [bp - 4], ax	;left in [bp - 4]  ;uss se kitna gaya jana hai

			mov di, word [bp - 2]	
			add di, word [bp - 4]
			mov ax, [bp + 12]    ;di now contains the starting point for square
			
			L2:
				mov cx, [bp + 8]
				rep stosw
				mov cx, [bp + 8]
				shl cx, 1
				add di, 160
				sub di, cx
				shr cx, 1
				sub [bp + 10], word 1
				mov dx, [bp + 10]
				cmp dx, 0
				jne L2
			
			popa
			
			mov sp, bp
			pop bp
			
			ret 10	
			
clearShape:

			pusha
			push ax
			push es
			push di
			mov ax,0xb800
			mov es,ax
			
			mov di,[bp+4]
			mov word [es:di],0x3020
			mov word [es:di-2],0x3020
			mov word [es:di-4],0x3020
			mov word [es:di+160],0x3020
			mov word [es:di+320],0x3020
			mov word [es:di-160],0x3020
			mov word [es:di-320],0x3020
			mov word [es:di-480],0x3020
			mov word [es:di+2],0x3020
			mov word [es:di+4],0x3020
			mov word [es:di+6],0x3020
			mov word [es:di-162],0x3020
			mov word [es:di-322],0x3020
			mov word [es:di-422],0x3020
			mov word [es:di-158],0x3020
			mov word [es:di-318],0x3020
			mov word [es:di-478],0x3020
			mov word [es:di-156],0x3020
			mov word [es:di-316],0x3020
			mov word [es:di-476],0x3020
			mov word [es:di+162],0x3020
			mov word [es:di+322],0x3020
			mov word [es:di+482],0x3020
			mov word [es:di+158],0x3020
			mov word [es:di+318],0x3020
			mov word [es:di+156],0x3020
			mov word [es:di+316],0x3020
			
			pop di
			pop es
			pop ax
			popa
			
			ret 2		
			
firstballoon:
			push di
			push si	
			push ax
			
			push word 0x582E	;magenta colour with grey dots within
			push word 4		    ;height
			push word 6		    ;width
			push word 17		;top
			push word 10		;left
			call printShape
			call randomnumber
			
			mov ax, 0xb800
			mov es, ax
	 
			push ax
			mov ah, 0x58
			mov al, 41h
			add al, [ran]
			
			mov di, 3384       ;tail
			mov word [es:di],0x30B3
			mov word [es:di+160], 0x30B3
			mov word [es:di-320], ax
			mov word [es:di+320], 0x30B3
			mov word [es:di+480], 0x30B3

			pop ax
			pop ax
			pop si
			pop di

			ret
		
bal1oon2:
			push di
			push si	
			push ax
		
			push word 0x182E	;cyan colour with grey dots within
			push word 4		    ;height
			push word 6		    ;width
			push word 13	    ;top
			push word 25 	    ;left
			call printShape
			call randomnumber

			mov ax, 0xb800
			mov es, ax

			push ax
			mov ah, 0x18
			mov al, 41h
			add al, [ran]
			
			mov di, 2774
			mov word [es:di],0x30B3
			mov word [es:di+160], 0x30B3
			mov word [es:di-320], ax
			mov word [es:di+320], 0x30B3
			mov word [es:di+480], 0x30B3

			pop ax
			pop ax
			pop si
			pop di

			ret
		
bal1oon3:
			push di
			push si	
			push ax
		
			push word 0xE82E	;yellow colour with grey dots within
			push word 4		    ;height
			push word 6		    ;width
			push word 15	    ;top
			push word 45	    ;left
			call printShape

			call randomnumber

			mov ax, 0xb800
			mov es, ax

			push ax
			mov ah, 0xE8
			mov al, 41h
			add al, [ran]

			mov di, 3134
			mov word [es:di],0x30B3
			mov word [es:di+160], 0x30B3
			mov word [es:di-320], ax
			mov word [es:di+320], 0x30B3
			mov word [es:di+480], 0x30B3

			pop ax
			pop ax
			pop si
			pop di

			ret
		
bal1oon4:
			push di
			push si	
			push ax
		
			push word 0x482E	;green colour with grey dots within
			push word 4		    ;height
			push word 6		    ;width
			push word 16	    ;top
			push word 70		;left
			call printShape
			call randomnumber

			mov ax, 0xb800
			mov es, ax

			push ax
			mov ah, 0x48
			mov al, 41h
			add al, [ran]

			mov di, 3344
			mov word [es:di],0x30B3
			mov word [es:di+160], 0x30B3
			mov word [es:di-320], ax
			mov word [es:di+320], 0x30B3
			mov word [es:di+480], 0x30B3

			pop ax
			pop ax
			pop si
			pop di

			ret		
clearballoon:
			push di
			push es
			push ax

			mov di,[bp+4]
			push di
			call clearShape

			mov ax, 0xb800
			mov es, ax   
			add di,320		;tail
			mov word [es:di],0x3020
			mov word [es:di+160], 0x3020
			mov word [es:di+320], 0x3020
			mov word [es:di+480], 0x3020

			pop ax
			pop es
			pop di

			ret 2
			
popbubble:
			push bx
			push es
			mov bx,0xb800
			mov es,bx
			mov di,320
check:
			cmp byte [es:di],al
			jne skip
			mov byte [popbit],1
			add word [scor],10
			jmp term
skip:
			add di,2
			cmp di,4000
			jne check
term:
			pop es
			pop bx
		    ret 
float: 
			mov ah,6
			mov al,1       ; no of lines to scroll up
			mov bh ,0xB8   ; blue colour of bg
			mov ch,0
			mov cl,0
			mov dl,79
			mov dh,24
			
			int 10h 
			ret
		
sleep:
			push cx
			mov cx, 0xFFFF
delay:
			loop delay
			pop cx
			
			ret
		
letssleep:

			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep
			call sleep

			ret

byescreen:
		push es
		push ax
		push di
		
		mov ax, 0xb800
		mov es, ax
		mov di, 0

next:  
        mov word [es:di], 0x7000
  		add di, 2
		cmp di, 4000
  		jne next
		
		call printendgame
		
  		pop di
  		pop ax
  		pop es
		
  		ret	
		
		
		

		
start: 
		 xor ax, ax
		 mov es, ax ; point es to IVT base
		 mov ax, [es:8*4]
		 mov [oldisr], ax ; save offset of old routine
		 mov ax, [es:8*4+2]
		 mov [oldisr+2], ax ; save segment of old routine
 
		 xor ax, ax
		 mov es, ax ; point es to IVT base
		 cli ; disable interrupts
		 mov word [es:8*4], timer2; store offset at n*4
		 mov [es:8*4+2], cs ; store segment at n*4+2
		 sti ; enable interrupts
		 
		call printsky
        mov cx, 10
		mov si, 0
		
		
		
floop:
		call printscore
		call printtime

		mov cl, al
		sub cl, bl
		
		call keypress
		cmp al,65
		jb moveon
		
		call popbubble
		cmp byte [popbit],1
		jne moveon
			;push 3996
			;push ax
			;call printnum
			push di
		call clearballoon
		mov byte [popbit],0
		
moveon:
	    ;mov ch,0x00
		;push 312
		;push cx
		;call printnum
		;cmp cl, 0x89
		;jae end2
		
		call float

		mov ax, si
		mov bl,10
		
		div bl          ;al divided by bl
		cmp ah, 0       ; ah = 0, means multiple of 10
		jne elsecase    
		
		call firstballoon  ;next set of balloons will only be printed if there has been 10 line gap
		call bal1oon2
		call bal1oon3
		call bal1oon4	
		
elsecase:
        call letssleep
		add si,1
		;sub cx,1
		;cmp cx, 0
		;jne floop	
	    jmp floop
		
end2:   
		 call byescreen

		 mov ax, [oldisr] ; read old offset in ax
		 mov bx, [oldisr+2] ; read old segment in bx
		 cli ; disable interrupts
		 mov [es:8*4], ax ; restore old offset from ax
		 mov [es:8*4+2], bx ; restore old segment from bx
		 sti
		 
		mov ax,0x4c00
		int 21h
		
timer2:
		 push ax
		 inc word [cs:tickcount]; increment tick count
		 cmp word[cs:tickcount],18
		 je timer3
		 jmp term_ret
		 
timer3:
		 mov word[cs:tickcount],0
		 dec word[seconds]
		 cmp word[seconds],0
		 je end2
		 push word 154
		 push word[seconds]
		 call printnum ; print tick count
		
term_ret:
		 mov al, 0x20
		 out 0x20, al ; end of interrupt
		 pop ax
		 iret ; return from interrupt
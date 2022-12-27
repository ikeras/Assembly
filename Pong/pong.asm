;FILE pong.ASM
;Entry to 666 byte contest
;Compiled as .com file, with tasm 4.0

.MODEL TINY                     ; Memory model for com files - near addressing (contained within 64k)
.186
.code                           ; Start of code segment
 ORG 100h                       
start:                          ; Start of initialization code
  mov ax , 0a000h                
  mov es , ax                   ; Point the segment register to video memory
  mov ah , 9                    
  mov dx , offset MSG           
  int 21h                       ; Output player message
  xor ax , ax                   
  int 16h                       ; Wait for keypress
  cmp ah , 3                    
  jnz oneplayer                 
  inc NumberOfPlayers           ; If the user hits 2 inc # of players
oneplayer:                      
  xor ax, ax                    
  int 33h                       ; Init mouse driver, if there is none, the first call to the button will return true, and exit the program
  mov ax , 13h                   
  int 10h                       ; Set 320x200x256 mode
  mov ax , 7                    
  xor cx, cx                    
  mov dx, 303                   
  int 33h                       ; Set Minx, & Maxx for the mouse
  mov ax,8                      
  mov cx,195                    
  mov dx,195                    
  int 33h                       ; Set Miny, & Maxy for the mouse
  mov ax,4                      
  mov cx,160                     
  mov dx,195                    
  int 33h                       ; Set start position of the mouse
main_loop:

  mov dx,03dah                  
VR:                             
  in al,dx                      
  test al, 8                    
  jnz VR                        
NoVR:                           
  in al,dx                      
  test al, 8                    
  jz NoVR                       ; Synch with vertical retrace - eliminates flicker
  xor ax , ax                   
  mov di , 62400                
  add di , currentx             
  Call Paddle_Stuff             ; Erase the first paddle
  mov di , currentx2            
  Call Paddle_Stuff             ; Erase the second paddle
  xor dl , dl
  lea si,Ball
  Call Ball_Stuff               ; Erase the ball
  mov ax , 3                    
  int 33h                       ; Get current mouse postion & button status
  cmp bx , 0                    
  jz stuff                      ; Mouse key pressed exit
  jmp done
stuff:
  cmp numberofplayers , 0       
  jz computer_player            ; Determine if second player, or computer
  mov ah , 1                    ; Check key status
  int 16h                       
  jz nohit                      
  xor ax , ax                   ; Read key
  int 16h                       
  cmp ah , 1                    
  jnz stuff2                    ; Hit esc so exit
  jmp done
stuff2:
  cmp ah , 75                   
  jz left2                      ; Hit left
  cmp ah , 77                   
  jz right2                     ; Hit right
  jmp nohit                     
left2:                          
  cmp currentx2 , 0              
  jbe nohit                     
  sub currentx2 , 8             ; Go left if not at wall
  jmp nohit                     
right2:                         
  cmp currentx2 , 302           
  jae nohit                     
  add currentx2 , 8             ; Go right if not at wall
  jmp nohit                     
computer_player:                
  cmp bally , 120               ;  If ball < 120 start moving paddle
  jnl nohit                     
  mov ax , ballx                
  cmp ax , currentx2            
  jg right3                     
  mov ax , currentx2            
  sub ax , ballx                
  cmp ax , 8                    
  jbe nohit                     ;  Abs(Ballx - Currentx)... if within 8
  sub currentx2 , 8             ;  then move
  jmp nohit                     
right3:                         
  sub ax , currentx2            
  cmp ax , 8                    
  jbe nohit                     
  cmp currentx2 , 300           
  jae nohit                     ;  Abs(Ballx - Currentx)... if within 8
  add currentx2 , 8             ;  then move
nohit:
  mov currentx , cx             
  mov ax , 2313                 
  mov di , 62400                
  add di , currentx             
  call Paddle_Stuff             ; Draw First paddle
  mov di , currentx2            
  mov ax , 771
  Call Paddle_Stuff             ; Draw Second Paddle
  call Move_Ball                ; Move the ball
  lea si,Ball
  mov dl , 12
  call Ball_Stuff               ; Draw the ball
  cmp gameover , 0              ;
  jnz done
  jmp main_loop
done:
  mov ax , 03h                  ; Text mode
  int 10h                        
  mov ax , totalhits
  mov di,OFFSET PrintBuffer+5
  mov bx,10                       ; base 10 division

PrintWLoop:
  dec di                          ; move one digit left
  xor dx,dx                       ; get last digit (into DL) and shift digits right
  div bx
  add dl,"0"                      ; covert to ASCII
  mov [di],dl                     ; save digit
  and ax,ax                       ; continue until all digits processed
  jnz PrintWLoop
  mov ah,9                        ; print number
  mov dx,di
  int 21h

  mov ah , 4ch                  ;
  int 21h                       ; Exit and stuff

;       I'm tired of commenting :)... big surprise, the whole thing is pretty 
; easy to understand.  I didn't use a double buffer because the way I had 
; it set up, it took more memory then simply drawing to the screen.  The mouse player 
; (1st player) always has the advantage over player 2, because of the non-
; relative way the mouse moves.  The computer is next to impossible to beat, the ball
; would have to be going REAL fast (33 hits actually) for you to win.


; Ax = Color
Paddle_Stuff PROC
  mov cx , 4
Y_loop:
  push cx
  mov cx , 8
  rep stosw
  add di , 304
  pop cx
loop y_loop
  ret
Paddle_Stuff ENDP


Ball_Stuff PROC
  mov bx , bally
  shl bx , 8
  mov ax , bally
  shl ax , 6
  add ax , bx
  mov di , ax
  add di , ballx
  mov cx,8        ; CX = height loop

DrawVert:
	mov bx,128      ; BX = 10000000b
	mov ax,8        ; AX = width loop

DrawHoriz:
	test [si],bx
	jz NoDraw
	mov es:[di],dl

NoDraw:
	inc di
	shr bx,1
	dec ax
	jnz DrawHoriz

	inc si
	add di,312      ; 320-height
	loop DrawVert
	ret
Ball_Stuff ENDP


Move_Ball PROC
  mov bx , 311
  sub bx , addy
  cmp ballx , bx
  jle df1
  mov left , 0
DF1:
  mov bx , addx
  cmp ballx , bx
  jnbe  DF2
  mov left , 255
DF2:
  cmp bally , 186
  jle DF3
  mov ax , ballx
  cmp ax , currentx
  jnl BGC
  mov bx , currentx
  sub bx , ballx
  jmp compare
BGC:
  mov bx , ballx
  sub bx , currentx
compare:
  cmp bx , 16
  jbe GoodHit
  mov gameover , 1
GoodHit:
  inc totalhits
  inc hits
  cmp hits , 10
  jnz nospeedup
  inc addx
  inc addy
  mov hits , 0
nospeedup:
  mov down , 255
DF3:
  cmp bally , 4
  ja df4
  mov ax , ballx
  cmp ax , currentx2
  jnl BGC2
  mov bx , currentx2
  sub bx , ballx
  jmp compare2
BGC2:
  mov bx , ballx
  sub bx , currentx2
compare2:
  cmp bx , 16
  jbe GoodHit2
  mov gameover , 1
GoodHit2:
  mov down , 0
DF4:
  cmp left , 0
  jz Go_Left
  mov ax , addx
  add ballx,ax
  jmp CheckDown
Go_Left :
  mov ax , addx
  sub ballx , ax
CheckDown:
  cmp down , 0
  jz Go_Down
  mov ax , addy
  sub bally, ax
  jmp DoneCheck
Go_Down:
  mov ax , addy
  add bally , ax
DoneCheck:
  ret
Move_Ball ENDP

vars:
currentX dw 0
currentx2 dw 160
Ballx dw 160
Bally dw 100
down db 255
left db 0
GameOver db 0
addx dw 1
addy dw 1
hits db 0
Totalhits dw 0
NumberOfPlayers db 0
MSG db "1||2 Players: $"
PrintBuffer		db	"00000$"

Ball            db  00111100b
                db  01111110b
                db  11011011b
                db  11111111b
                db  10111101b
                db  11000011b
                db  01111110b
                db  00111100b


End START

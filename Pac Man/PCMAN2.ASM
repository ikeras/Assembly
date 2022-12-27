MSpd equ 16 ; max speed

; PC Man
;
; There are eight levels, the last one being at night.  Eat all the
; pellets to advance a level.  If you get hit, the game is over.


; by coder (junior@fred.net) 
; and Cyrino (cyrino@fred.net)


.MODEL TINY
.186                ; shrinks code size ;)
.CODE

ORG 100h

Main:
    mov ax,0A000h   ; set es
    mov es,ax       ;
    mov ax,13h      ; mode 13h
    int 10h         ;

NewGame:
                    ; set default direction (left)
    mov BYTE PTR PacDir,1
    mov DCount,8    ; init move count
    mov Xpos,15     ; set Pacman X,Y
    mov Ypos,11     ;
    mov Pellets,269 ; num pellets
    mov al,WallClr  ; new wall color
    cmp al,16       ;
    jz GameOver     ; (you won)
    dec al          ;
    and al,al       ;
    jnz Daylight    ;
    mov al,16       ; night time

Daylight:
    mov WallClr,al  ; draw map
    call BlitMap    ;

GameLoop:
    mov dh,1        ; draw
    call DrawErase  ;
    call Retrace    ; wait for retrace
    xor dh,dh       ; erase
    call DrawErase  ;
    call MovePac    ;
    jnc GameLoop    ; CF is exit flag

    mov ax,Pellets  ; dead or end of level?
    and ax,ax       ;
    jz NewGame      ;

GameOver:
    mov ax,3        ; text mode
    int 10h         ;
    mov ah,4ch      ; exit
    int 21h         ;


;-----------------------------------------------;
; DrawErase - draws or erases Pacman and ghosts ;
;                                               ;
; in:  DH = 0 erase                             ;
;         = 1 draw                              ;
;-----------------------------------------------;

DrawErase PROC
    xor dl,dl
    mov ax,Xpos
    mov di,Ypos
    and dh,dh
    jz ErasePac
    mov dl,14       ; Pacman color

ErasePac:
    lea si,Pacman
    call Blit8x8    ; place Pacman (doesn't alter dx)
    mov cx,4        ; 4 ghosts

DrawGhosts:
    lea si,Xpos     ; set X
    add si,cx       ;
    add si,cx       ;
    mov ax,[si]     ;
    lea si,Ypos     ; set Y
    add si,cx       ;
    add si,cx       ;
    mov di,[si]     ;
    and dh,dh       ; test draw/erase
    jz EraseGhosts  ;
    lea si,Color    ; set Color
    add si,cx       ;
    mov dl,[si]     ;

EraseGhosts:
    lea si,Ghost    ; place ghost
    push cx         ;
    call Blit8x8    ;
    pop cx          ;
    loop DrawGhosts
    ret
DrawErase ENDP


;-----------------------;
; MovePac - move Pacman ;
;-----------------------;

MovePac PROC
    xor bl,bl       ; flag for default movement
    mov cx,Xpos     ; load current position
    mov dx,Ypos     ;
    mov ah,1        ; check for keypress
    int 16h         ;
    jz Default      ;
    inc bx          ; flag for manual movement
    xor ah,ah       ; remove key from buffer
    int 16h         ;
    cmp ah,4bh      ; left arrow
    jz Left         ;
    cmp ah,4dh      ; right arrow
    jz Right        ;
    cmp ah,48h      ; up arrow
    jz Up           ;
    cmp ah,50h      ; down arrow
    jz Down         ;

ExitPacman:
    stc             ; set exit flag
    ret

Left:
    dec cx
    mov BYTE PTR PacDir,1
    jmp CheckMove

Right:
    inc cx
    mov BYTE PTR PacDir,2
    jmp CheckMove

Up:
    dec dx
    mov BYTE PTR PacDir,3
    jmp CheckMove

Down:
    inc dx
    mov BYTE PTR PacDir,4
    jmp CheckMove

MaybeDefault:
    dec bx          ; check for default or manual
    jnz DontMove    ;
                    ; bl is now 0 for default

Default:
    mov ax,PacDir   ; check default dir
    dec ax          ; test left
    jz Left         ;
    dec ax          ; test right
    jz Right        ;
    dec ax          ; test up
    jz Up           ;
    inc dx          ; move down

CheckMove:
    dec DCount      ; check movement counter
    jnz DontMove    ;
    mov DCount,MSpd ; reset counter and move PC Man
    mov ax,cx
    mov di,dx
    call CheckXY    ; (doesn't alter bx, cx or dx)
    and al,al       ; empty space
    jz TestGhosts   ;
    cmp al,WallClr  ; wall
    jz MaybeDefault ;
    dec Pellets     ;
    jz ExitPacman   ; next level

GoodMove:
    mov Xpos,cx     ; update coords
    mov Ypos,dx     ;

DontMove:
    clc             ; clear exit flag
    ret

TestGhosts:
    mov bx,4        ; 4 ghosts

TestOneGhost:
    lea si,Xpos     ; test X
    add si,bx       ;
    add si,bx       ;
    cmp cx,[si]     ;
    jnz NextGhost   ;
    lea si,Ypos     ; test Y
    add si,bx       ;
    add si,bx       ;
    cmp dx,[si]     ;
    jz ExitPacman   ; dead

NextGhost:
    dec bx
    jnz TestOneGhost
    jmp GoodMove
MovePac ENDP


;------------------------;
; CheckXY - checks (X,Y) ;
;                        ;
; in:  AX = X            ;
;      DI = Y            ;
;                        ;
; out: AL = color        ;
;------------------------;

CheckXY PROC
    shl ax,3        ; convert to screen coords
    shl di,3        ;
    add ax,320*4+4  ; check middle of block
    mov si,di       ; DI = Y*320+X
    shl di,8        ;
    shl si,6        ;
    add di,si       ;
    add di,ax       ;
    mov al,es:[di]  ; get color
    ret
CheckXY ENDP


;------------------------;
; BlitMap - displays map ;
;                        ;
; in:  AL = color        ;
;------------------------;

BlitMap PROC
    lea si,Map
    xor di,di
    mov cx,16
    mov ah,al

DrawVert2:
    push cx
    mov cx,4

Bit1:
    mov bx,10000000b
    mov dx,8

DrawHoriz2:
    test [si],bx
    jz NoDraw2
    pusha
    mov bp,8

HLoop:
    mov cx,4
    rep stosw
    add di,312
    dec bp
    jnz hloop
    popa
    jmp donedraw

NoDraw2:
    add di,320*4+4
    mov al,13
    stosb
    sub di,320*4+5
    mov al,ah

donedraw:
    add di,8
    shr bx,1
    dec dx
    jnz DrawHoriz2
    inc si
    loop bit1

    add di,2304
    pop cx
    loop DrawVert2

    xor ax,ax           ; ghost dots
    mov cl,4*8          ; 4 down
    mov di,6*8*320+12*8 ; starting at (6,12)

EraseGhostDots:
    push cx
    mov cl,8*4          ; 8 right
    rep stosw
    pop cx
    add di,320-64
    loop EraseGhostDots
    ret
BlitMap ENDP


;------------------------------;
; Blit8x8 - Blits 8x8 bitmap   ;
;                              ;
; in:  AX = X                  ;
;      DI = Y                  ;
;      DL = color              ;
;      SI = pointer to bitmap  ;
;------------------------------;

Blit8x8 PROC
    shl ax,3        ; convert to screen coords
    shl di,3        ;
    mov bx,di       ; DI = Y*320+X
    shl di,8        ;
    shl bx,6        ;
    add di,bx       ;
    add di,ax       ;
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
Blit8x8 ENDP


;----------------------------------------;
; Retrace - waits for a verticle retrace ;
;----------------------------------------;

Retrace PROC
    mov dx,3dah     ; status register

VRT:                ; wait for retrace to end
    in al,dx        ;
    test al,8       ;
    jnz VRT         ;

NoVRT:              ; wait for new retrace to start
    in al,dx        ;
    test al,8       ;
    jz NoVRT        ;
    ret
Retrace ENDP


;======;
; DATA ;
;======;

; 32x16 map (256x128 screen)

;           Pac  Ghosts
;           ---  --------------
Xpos    dw   ?,  13, 15, 16, 18
Ypos    dw   ?,   7,  7,  8,  8
Color   db   ?,   9, 10, 12, 13

Pellets dw  ?
WallClr db  8

PacDir  dw  ?       ; 1 = left, 2 = right, 3 = up, 4 = down
DCount  db  ?
Pacman  db  00111100b
        db  01111110b
        db  11011011b
        db  11111111b
        db  10111101b
        db  11000011b
        db  01111110b
        db  00111100b

Ghost   db  00111100b
        db  01111110b
        db  11011011b
        db  11111111b
        db  11100111b
        db  11100111b
        db  11111111b
        db  10101010b

Map     dw  1111111111111111b
        dw  1111111111111111b
        dw  0000000110000000b
        dw  0000000110000000b
        dw  1110000110111000b
        dw  0001110110000111b
        dw  1110000110111000b
        dw  0001110110000111b
        dw  0000000010000000b
        dw  0000000100000000b
        dw  0001111011111000b
        dw  0001111101111000b
        dw  0001000010000000b
        dw  0000000100001000b
        dw  0001000010111100b
        dw  0011110100001000b
        dw  0001000010111100b
        dw  0011110100001000b
        dw  0001000010000000b
        dw  0000000100001000b
        dw  0001111111111000b
        dw  0001111111111000b
        dw  0000000010000000b
        dw  0000000100000000b
        dw  1110000110111000b
        dw  0001110110000111b
        dw  1110000110111000b
        dw  0001110110000111b
        dw  0000000110000000b
        dw  0000000110000000b
        dw  1111111111111111b
        dw  1111111111111111b

END Main

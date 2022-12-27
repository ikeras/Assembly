;   л      л   лл   л      л 
;    л лл л   л  л   л лл л 
;     л  л     лл     л  л   , Inc. All rights reserved.
Public PutWindow,GetWindow,MouseInit,Pointon,Pointoff,Video,Pset,MouseXY,SetMouse
Public MinMax,ChangeIcon,Cls,SetPal,PutImage,GotoXY
.MODEL large
.DATA
HorizHs dw     7     
VertHs  dw     7
     Hourglass dw 0000000000000000b
               dw 0111111111111110b 
               dw 1011111111111101b 
               dw 1011111111111101b 
               dw 1101111111111011b 
               dw 1110111111110111b 
               dw 1111011111101111b 
               dw 1111101111011111b 
               dw 1111101111011111b 
               dw 1111011111101111b 
               dw 1110111111110111b 
               dw 1101111111111011b 
               dw 1011111111111101b 
               dw 1011111111111101b 
               dw 0111111111111110b 
               dw 0000000000000000b 
               
               dw 1111111111111111b
               dw 1000000000000001b 
               dw 0100000000000010b 
               dw 0100000000000010b 
               dw 0010000000000100b 
               dw 0001000000001000b 
               dw 0000100000010000b 
               dw 0000010000100000b 
               dw 0000010000100000b 
               dw 0000100000010000b 
               dw 0001000000001000b 
               dw 0010000000000100b 
               dw 0100000000000010b 
               dw 0100000000000010b 
               dw 1000000000000001b 
               dw 1111111111111111b 

.CODE

;Puts a rectangular area on the screen from an array,
;does not put "transparent"(black) pixels!
PutImage PROC
     ARG  Segm:Word,ofst:Word,lenty:word,lentx:word,x1:word
     push bp
     mov bp,sp
     push ds
     mov ax,0a000h
     mov es,ax
     mov di,x1
     mov ds,[segm]
     mov si,[ofst]
     mov cx,lenty
a_loop:
     push cx
     push di
     mov cx,lentx
     rep movsb
     pop di
     add di,320
     pop cx
loop a_loop
     pop ds
     pop bp
     ret 10 
PutImage ENDP

PutWindow PROC
     ARG  Segm:Word,ofst:Word,lenty:word,lentx:word,x1:word
     push bp
     mov bp,sp
     push ds
     mov ax,0a000h
     mov es,ax
     mov di,x1
     mov ds,[segm]
     mov si,[ofst]
     mov cx,lenty
y_loop:
     push cx
     push di
     mov cx,lentx
x_loop:
     mov dl,ds:[si]
     cmp dl,0
     jz ok
     movsb
     jmp done_x
ok:
     inc di
     inc si
done_x:
loop x_loop
     pop di
     add di,320
     pop cx
loop y_loop
     pop ds
     pop bp
     ret 10 
PutWindow ENDP

;Gets a rectangular area of the screen into an array.
GetWindow PROC
     Arg segm:Word,Ofst:Word,lenty:word,lentx:word,x1:word
     push bp
     mov bp,sp
     push ds
     mov ax,0a000h
     mov ds,ax
     mov si,x1
     mov es,[segm]
     mov di,[ofst]
     mov cx,lenty
Cool:
     push cx
     push si
     mov cx,lentx
     rep movsb
     pop si
     add si,320
     pop cx
loop cool
     pop ds
     pop bp
     ret  10
GetWindow ENDP

;Initializes the mouse using interrupt 33h (Mouse Driver), function 1
MouseInit PROC
     push bp
     mov bp,sp
     mov ax,0
     int 33h
     pop bp
     ret
MouseInit ENDP

;Turns on the mouse pointer
PointOn PROC
     push bp
     mov bp,sp
     mov ax,1
     int 33h
     pop bp
     ret
PointOn ENDP

;Turns the mouse pointer off
PointOff PROC
     push bp
     mov bp,sp
     mov ax,2
     int 33h
     pop bp
     ret
PointOff ENDP

;Sets the screen mode to value at top of stack
Video PROC
     Arg videomode:Word
     push bp
     mov bp,sp
     mov ax,videomode
     mov ah,0
     int 10h
     pop bp
     ret 2
Video ENDP

;Plots a pixel in screen mode 13h
Pset PROC
     Arg Colour:word,y:word,x:word
     push bp
     mov bp,sp
     push ds
     mov ax,0a000h
     mov es,ax
     mov ax,320
     mov bx,y
     mul bx
     add ax,x
     mov bx,ax
     mov ax,colour
     mov es:[bx],ax
     pop ds
     pop bp
     ret 6
Pset ENDP

;Returns the x and y of the mouse, also returns the button status
MouseXY PROC
     Arg Segm:Word,Ofst:Word
     push bp
     mov bp,sp
     mov ax,3
     int 33h
     mov es,[segm]
     mov ax,bx
     mov bx,[ofst]
     mov es:[bx],ax
     add bx,2
     mov es:[bx],cx
     add bx,2
     mov es:[bx],dx
     mov sp,bp
     pop bp
     ret 4
MouseXY ENDP

;Set the current mouse position
SetMouse PROC
     Arg y:Word,x:word
     push bp
     mov bp,sp
     mov ax,4
     mov cx,x
     mov dx,y
     int 33h
     mov sp,bp
     pop bp
     ret 4
SetMouse ENDP

MinMax PROC
     ARG MaxY:word,MaxX:word,MinY:word,MinX:Word
     push bp
     mov bp,sp
     mov ax,7
     mov cx,MinX     
     mov dx,MaxX
     int 33h
     mov ax,8
     mov cx,MinY
     mov dx,MaxY
     int 33h
     pop bp
     ret 8
MinMax ENDP

ChangeIcon PROC
     push bp
     mov bp,sp
     mov ax,09h
     mov bx,HorizHS
     mov cx,VertHs
     push es
     push ds
     pop es
     mov dx,Offset Hourglass
     int 33h
     pop es
     pop bp
     ret
ChangeIcon ENDP

Cls PROC
     push bp
     mov bp,sp
     mov di,0a000h
     mov es,di
     mov di,0
     mov cx,32000
     mov ax,0
     rep stosw
     pop bp
     ret
Cls ENDP

SetPal PROC
     Arg Blue:Byte,Green:Byte,Red:Byte,Color:Byte
     push bp
     mov bp,sp
     mov al,color
     mov dx,3c8h
     out dx,al
     mov dx,3c9h
     mov al,Red
     out dx,al
     mov al,Green
     out dx,al
     mov al,Blue
     out dx,al
     pop bp
     ret 8
SetPal ENDP

GotoXY PROC
          ARG row:Byte,col:byte
          push bp
          mov bp,sp
          mov dh,row
          mov dl,col
          mov bh,0
          mov ah,2
          int 10h
          pop bp
          ret 2
GotoXY ENDP

end

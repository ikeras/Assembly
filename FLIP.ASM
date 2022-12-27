.Alpha
.Model Large
.Data
.Code
Public Flip,Hline,Cls,Hline2

Hline PROC
      ARG Where:Word,Col:Byte,Y:Word,X2:Word,X1:Word=LOCALSPACE
      push bp
      mov bp,sp
      push ds
      mov   ax,where
      mov   es,ax
      mov   ax,y
      mov   di,ax
      shl   ax,8
      shl   di,6
      add   di,ax
      add   di,x1

      mov   cx,x2
      sub   cx,x1
      cmp   cx,0
      jle   End_Label
Loop1 :
      mov   al,es:[di]
      add   al,col
      stosb
      loop  loop1
End_Label:
      pop ds
      pop bp
      ret LOCALSPACE
Hline ENDP

Hline2 PROC
      ARG Where:Word,Col:Byte,Y:Word,X2:Word,X1:Word=LOCALSPACE
      push bp
      mov bp,sp
      push ds
      mov   ax,where
      mov   es,ax
      mov   ax,y
      mov   di,ax
      shl   ax,8
      shl   di,6
      add   di,ax
      add   di,x1

      mov   cx,x2
      sub   cx,x1
      cmp   cx,0
      jle   End_Label2
Loop2 :
      mov   al,col
      stosb
      loop  loop2
End_Label2:
      pop ds
      pop bp
      ret LOCALSPACE
Hline2 ENDP


Cls PROC
      ARG Col:Byte,Where:Word=LOCALSPACE
      push bp
      mov bp,sp
      push ds
      push    es
      mov     cx, 32000
      mov     es,[where]
      xor     di,di
      mov     al,[col]
      mov     ah,al
      rep     stosw
      pop     es
      pop     ds
      pop     bp
      ret     LOCALSPACE
Cls ENDP

Flip PROC
     Arg segm:word,ofst:word
     push bp
     mov bp,sp
     push ds
     .386
     cld
     mov ax,[segm]
     mov ds,ax
     mov si,[ofst]
     mov ax,0a000h
     mov es,ax
     mov di,0
     mov cx,16000
     xor eax , eax
     rep movsd
     pop ds
     pop bp
     ret 4
Flip ENDP

end

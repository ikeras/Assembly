     .MODEL TINY
     .STACK 256
     .DATA
cr   EQU  13
lf   EQU  10

     DATASEG

     infile    DW   0
     outfile   DW   0
     Buffer    DB 2048 DUP (?)
     diskFull  DB cr,lf,'**ERROR:Disk is full dumbass!',0
     Err1 DB  'File not Found',0
     Err2 DB  'Usage Kopy <Source> <Destination>',0
     Err3 DB  'Unable to open file!',0
     Err4 DB  'Unable to create file!',0
     Err5 DB  'Error Reading to file!',0
     Err6 DB  'Error Writing to file!',0

     .CODE

EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc

Copy PROC
     mov ax,@Data
     mov es,ax
     Call GetParams
     Call ParamCount
     cmp dx,2
     jz Ok1
     mov di,Offset Err2
     Call StrWrite
     Jmp Exit
Ok1:
     xor cx,cx
     Call GetOneParam
     mov dx,di
     xor al,al
     mov ah,3dh
     int 21h
     jnc Ok2
     mov di,offset Err1
     Call StrWrite
     Jmp Exit
Ok2:
     mov [infile],ax
     mov cx,1
     Call GetOneParam
     mov dx,di
     xor cx,cx
     mov ah,3ch
     int 21h
     jnc ok3
     mov di,offset Err4
     Call StrWrite
     jmp Exit
ok3:
     mov [outfile],ax
write:
     mov ah,3fh
     mov bx,[infile]
     mov cx,2048
     mov dx,offset Buffer
     int 21h
     jnc Good
     mov di,offset Err5
     Call StrWrite
     Jmp Close
Good:
     mov cx,ax
     mov ah,40h
     mov bx,[outfile]
     mov dx,offset Buffer
     int 21h
     jnc Great
     Mov di,offset Err6
     Call StrWrite
     Jmp Close
Great:
     Cmp Ax,2047
     jna Close
     jmp write
Close:
     mov bx,[infile]
     mov ah,3eh
     int 21h
     mov bx,[outfile]
     mov ah,3eh
     int 21h
Exit:
     mov ah,04ch
     mov al,0
     int 21h
Copy ENDP

StrWrite PROC
     cmp cx,0
     jnz Ready
     push ax
     push di
     xor al,al
     mov cx,0ffffh
     cld
     repnz scasb
     not cx
     dec cx
     pop di
     pop ax
Ready:
     push ax
     push bx
     push dx
     mov bx,1
     mov dx,di
     mov ah,40h
     int 21h
     pop  dx
     pop bx
     pop ax
     ret
StrWrite ENDP
END

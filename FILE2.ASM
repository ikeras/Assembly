Public Copyit,DelFile,SetAttr,WipeFile
.Model Large
.Data
     InFile DW 0
     OutFile DW 0
     Buffer DB 2048 DUP (0)
     What DB 'What the hell',0
.Code

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

Copyit PROC
     Arg Seg2:Word,Filename2:Word,Seg1:Word,Filename:Word
     Push bp
     mov bp,sp
     push ds
     mov ds,[Seg1]
     Inc Filename
     mov dx,Offset FileName
     xor al,al
     mov ah,3dh
     int 21h
     jnc Ok1
     mov di,offset Filename
     Call StrWrite
     jmp Exit
Ok1:
     mov [infile],ax
     Inc Filename2
     mov ds,[Seg2]
     mov dx,Filename2
     xor cx,cx
     mov ah,3ch
     int 21h
     jnc ok2
     mov di,offset Filename2
     Call StrWrite
     jmp Close
Ok2:
     mov [outfile],ax
Read:
     mov ah,3fh
     mov bx,[infile]
     mov cx,2048
     mov dx,offset Buffer
     int 21h
     jnc Write
     mov di,offset What
     Call StrWrite
     jmp Close
Write:
     mov cx,ax
     mov ah,40h
     mov bx,[outFile]
     mov dx,offset Buffer
     int 21h
     jnc Good
     jmp Close
Good:
     Cmp ax,2047
     jna Close
     jmp Read
Close:
     mov bx,[infile]
     mov ah,3eh
     int 21h
     mov bx,[outfile]
     mov ah,3eh
     int 21h
Exit:
     pop ds
     mov sp,bp
     pop bp
     ret 4
Copyit ENDP

DelFile PROC
     ARG FileName:Word
     push bp
     mov bp,sp
     push ds
     Inc Filename
     mov ah,41h
     mov dx,offset Filename
     int 21h
     pop ds
     mov sp,bp
     pop bp
     ret 2
DelFile EndP
     
SetAttr PROC     
     ARG Attribute:Word,Filename:Word
     push bp
     mov bp,sp
     push ds
     Inc Filename
     mov dx,offset filename
     mov al,01h
     mov cx,Offset Attribute
     mov ah,43h
     int 21h
     pop ds
     mov sp,bp
     pop bp
     ret 4
SetAttr ENDP

WipeFile PROC  
     Arg Size2:Word,Filename:Word
     Push bp 
     mov bp,sp
     push ds
     Inc Filename
     mov dx,Offset Filename
     mov al,2
     mov ah,3dh
     int 21h
     jnc Tallyho
     Jmp Exit2
TallyHo:
     mov [infile],ax
Writing:
     mov ah,40h
     mov bx,[infile]
     mov cx,2048
     mov dx,offset Buffer
     int 21h
     jc Close2
     Dec Size2
     Cmp Size2,0
     jz Close2
     jmp Writing
Close2:
     mov bx,[infile]
     mov ah,3eh
     int 21h
     mov ah,41h
     mov dx,offset Filename
     int 21h
Exit2:
     Pop Ds
     mov sp,bp
     pop bp
     ret 2
WipeFile ENDP
End


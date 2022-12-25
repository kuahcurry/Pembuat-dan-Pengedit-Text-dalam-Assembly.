.MODEL SMALL
.DATA
    matrix      db 80*25 dup(?),'$' 
    matrix_2    db 22 dup(?)           
    row         db 2                
    column      db 0                
    curr_line   db 2                
    curr_char   db 0                
    deco1       db '  =================================================$'
    deco2       db '||           Pembuat dan Pengedit Text             ||$'
    deco3       db '||                                                 ||$'
    deco4       db '||       ESC = Keluar || CTRL+S = Simpan File      ||$'
    deco5       db '||              ARROW KEYS = Navigasi              ||$'
    deco6       db '  =================================================$'
    docPrompt   db 'Masukkan Nama Dokumen (.txt): $'
    docName     dw 50 dup(?),'$'
    openPrompt  db 'Masukkan Nama Dokumen untuk Membuka file: $'
    HANDLE      dw ? 
    header      db 80 dup('='),'$'    
    color       db 3*15+15
    
          
.CODE 

;=========== MAKRO ============
newline macro
    mov dl, 10       
    mov ah, 2
    int 21h   
    mov dl, 13       
    mov ah, 2
    int 21h
endm
remove macro
    mov dx, 8        
    mov ah, 2
    int 21h
    mov dx, 32       
    mov ah, 2
    int 21h
    mov dx, 8        
    mov ah, 2
    int 21h
endm
goto_pos macro row, col
    mov ah, 02h      
    mov dh, row
    mov dl, col
    int 10h
endm
clrScrn macro
    mov ah, 02h    
    mov dh, 0
    mov dl, 0
    int 10h            
    mov ah, 0Ah    
    mov al, 00h    
    mov cx, 2000  
    int 10h        
endm 
debug macro arg
    mov dx, arg    
    mov ah, 2
    int 21h
endm

;=============== PROSEDUR =================
start_menu proc
    goto_pos 5, 12
    mov dx, offset deco1      
    mov ah, 9
    int 21h
    goto_pos 6, 12
    mov dx, offset deco2      
    mov ah, 9
    int 21h
    goto_pos 7, 12
    mov dx, offset deco3      
    mov ah, 9
    int 21h
    goto_pos 8, 12
    mov dx, offset deco4      
    mov ah, 9
    int 21h
    goto_pos 9, 12
    mov dx, offset deco5      
    mov ah, 9
    int 21h
    goto_pos 10, 12
    mov dx, offset deco6      
    mov ah, 9
    int 21h
    goto_pos 13, 12
    mov dx, offset docPrompt  
    mov ah, 9
    int 21h
    
    mov cx, 0  
    mov si, offset docName
    input_char: 
    mov ah, 1
    int 21h
    cmp al, 13          
    je return
    cmp al, 8           
    je remove_char
    inc cx              
    mov [si], al
    inc si
    jmp input_char
    
    remove_char:
    cmp cx, 0
    je setPos_ret
    dec cx              
    dec si
    mov [si], 00h
    
    mov dl, 32          
    mov ah, 2           
    int 21h             
    mov dl, 8           
    mov ah, 2           
    int 21h             
    jmp input_char
    
    setPos_ret:
    goto_pos 13, 40
    jmp input_char 
    
    return:    
    ret 
start_menu endp

upper_bar proc
    goto_pos 0 0
    mov dx, offset docName  
    mov ah, 9
    int 21h
    goto_pos 1 0
    mov dx, offset header
    mov ah, 9
    int 21h
    
    ret            
upper_bar endp

;============ PROGRAM UTAMA ===============
MAIN PROC
    mov ax, @DATA
    mov ds, ax 
    
    mov ah, 01h        
    mov cx, 07h        
    int 10h             
    clrScrn
    call start_menu     
    clrScrn            
    call upper_bar     
    
    goto_pos 2, 0      
    
    mov si, offset matrix 
    mov di, offset matrix_2
    MAIN_LOOP:                                   
    mov ah, 00h
    int 16h
    cmp ah, 01h            
    je EXIT
    cmp al, 13h            
    je SAVE
    cmp al, 0Fh            
    je OPEN
    cmp ah, 48h            
    je UP
    cmp ah, 50h            
    je DOWN
    cmp ah, 4Bh            
    je LEFT
    cmp ah, 4Dh            
    je RIGHT                             
    cmp ah, 1Ch            
    je ENTER                                    
    cmp ah, 0Eh            
    je BACKSPACE       
    
    cmp column, 79
    je ENTER
    mov dl, al             
    mov ah, 2
    int 21h        
    mov [si], al           
    inc si
    inc curr_char          
    inc column             
    goto_pos row, column
    jmp MAIN_LOOP
         
    EXIT:
    mov ah, 4ch
    int 21h
        
    SAVE:
    mov ah, 3Ch             
    mov cx, 0               
    mov dx, offset docName  
    int 21h                 
    mov ah, 3Dh             
    mov al, 1               
    mov dx, offset docName  
    int 21h
    mov HANDLE, ax          
    mov ah, 40h             
    mov bx, HANDLE          
    mov cx, 2000            
    mov dx, offset matrix   
    int 21h
    jmp MAIN_LOOP  
    
    OPEN:
    goto_pos 22 0    
    mov dx, offset openPrompt
    mov ah, 9
    int 21h
    mov cx, 0  
    mov di, offset docName
    input_char2: 
    mov ah, 1
    int 21h
    cmp al, 13          
    je return2
    cmp al, 8           
    je remove_char2
    inc cx              
    mov [di], al
    inc di
    jmp input_char2
    remove_char2:
    cmp cx, 0
    je setPos_ret2
    dec cx              
    dec di
    mov [di], 00h
    mov dl, 32          
    mov ah, 2           
    int 21h             
    mov dl, 8           
    mov ah, 2           
    int 21h             
    jmp input_char2
    setPos_ret2:
    goto_pos 22, 29
    jmp input_char2
    return2:            
    clrScrn
    call upper_bar 
    goto_pos 2, 0           
    mov ah, 0x3d             
    mov al, 00               
    mov dx, offset docName
    int 21h
    mov HANDLE, ax           
    mov ah, 0x3f             
    mov bx, HANDLE
    mov cx, 1760             
    mov dx, offset matrix    
    int 21h       
    mov dx, offset matrix    
    mov ah, 9                
    int 21h                  
    jmp MAIN_LOOP            
           
    UP:
    cmp row, 2
    je MAIN_LOOP 
    dec curr_line
    dec row
    goto_pos row, column
    jmp MAIN_LOOP
         
    DOWN:
    inc curr_line
    inc row
    goto_pos row, column 
    jmp MAIN_LOOP
           
    LEFT:
    dec column
    goto_pos row, column
    jmp MAIN_LOOP
    
    RIGHT:
    inc column
    goto_pos row, column
    jmp MAIN_LOOP
    
    ENTER:      
    newline         
    mov [si], 10    
    inc si
    mov dl, curr_char
    mov [di], dl
    inc di
    inc curr_line
    mov curr_char, 0
    inc row             
    mov column, 0       
    goto_pos row, 0     
    jmp MAIN_LOOP
    
    BACKSPACE:
    ;JIKA BENAR
    cmp curr_line, 2    
    ;EKSEKUSI INI
    je rmv              
    ;JIKA BENAE
    cmp curr_char, 0    
    ;EKSEKUSI INI
    je goBackLine       
    ;LAINNYA
    remove
    dec curr_char
    dec column
    dec si
    mov [si], 00h
    jmp MAIN_LOOP
    rmv:
    remove
    dec curr_char
    dec column
    dec si              
    mov [si], 00h       
    jmp MAIN_LOOP
    goBackLine:
    dec curr_line
    dec row
    dec di
    mov dl, [di]
    mov column, dl
    goto_pos curr_line, dl  
    mov dl, [di]        
    mov curr_char, dl   
    jmp MAIN_LOOP
        
MAIN ENDP
END MAIN
print16:
    push bx
    mov bh, 0x00        ; Page vidéo 0
    mov bl, 0x0F        ; Attribut blanc sur noir

.print_loop:
    lodsb               ; AL = byte depuis DS:SI, puis SI++
    test al, al         ; Test si AL == 0x00 (fin de chaîne)
    jz .print_done

    mov ah, 0x0E        ; Fonction BIOS: teletype output
    int 0x10

    jmp .print_loop

.print_done:
    pop bx
    ret

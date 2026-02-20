disk_load:
    push dx
    push ax

    mov ah, 0x02        ; Fonction BIOS : lecture de secteurs
    mov al, dh          
    mov ch, 0x00        
    mov cl, 0x02        ; Secteur de départ = 2 (secteur 1 = MBR, on saute le Stage1)
    mov dh, 0x00

    int 0x13       
    jc .disk_error      ; Si Carry Flag = 1 → erreur hardware

    pop ax              ; Récupère le nombre de secteurs demandés
    pop dx
    cmp al, dh          ; AL = secteurs réellement lus | DH = secteurs demandés
    jne .sectors_error

    ret

.disk_error:
    mov si, DISK_ERROR_MSG
    call print16
    jmp $               ; Halt

.sectors_error:
    mov si, SECTORS_ERROR_MSG
    call print16
    jmp $               ; Halt

DISK_ERROR_MSG    db "[ERROR] Disk read failed!", 0x0A, 0x0D, 0
SECTORS_ERROR_MSG db "[ERROR] Wrong sector count!", 0x0A, 0x0D, 0

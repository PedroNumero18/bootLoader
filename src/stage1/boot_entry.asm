[BITS 16]
[ORG 0x7c00]

global start
start:
    cli

    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7c00

    sti
    mov bx, 0x0900      ; Destination : adresse du Stage 2
    mov es, bx
    mov bx, 0x0000  
    mov dh, 0x01        ; Nombre de secteurs à lire (Stage 2 = 1 secteur actuel)
    call disk_load
    jmp 0x0900:0x0000


%include "src/common/print.asm"
%include "src/stage1/disk_load.asm"

times 510 - ($ - $$) db 0x00
dw 0xAA55
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

    mov si, msg ;just for a Hello World

print:
    lodsb; load byte at ds:si(segment: offset) to AL register and incrment SI
    cmp al, 0
    je done
    mov ah, 0xE
    int 0x10
    jmp print

done:
    cli
    hlt ;halt the cpu

msg: db 'Hello World!', 0

times 510 - ($ - $$) db 0 ; to fill the remaining space with zeros untils we reach 512 bytes

dw 0xAA55
print16:
    lodsb; load byte at ds:si(segment: offset) to AL register and incrment SI
    cmp al, 0
    je done
    mov ah, 0xE
    int 0x10
    jmp print

done:
    cli
    hlt ;halt the cpu
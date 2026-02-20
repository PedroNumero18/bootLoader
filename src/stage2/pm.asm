[BITS 16]
loadPM:
    cli
    lgdt[gdtDesc]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp codeOffset:PMode

[BITS 32]
PMode:
    mov ax, dataOffset
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp

    call enableA20

    jmp $ ; tempo remplacer par kernel
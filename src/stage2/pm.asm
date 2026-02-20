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

    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $ ; tempo remplacer par kernel
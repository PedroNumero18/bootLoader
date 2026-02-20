codeOffset equ 0x8
dataOffset equ 0x10

gdtStart:
    dd 0x00000000
    dd 0x00000000

    ;Code Segment descriptor
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base
    db 0x00         ; Base
    db 10011010b    ; Access byte
    db 11001111b    ; Flags
    db 0x00         ; Base

        ;Data Segment descriptor
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base
    db 0x00         ; Base
    db 10010010b    ; Access byte
    db 11001111b    ; Flags
    db 0x00         ; Base
gdtEnd:

gdtDesc:
    dw gdtEnd - gdtStart - 1; Size of GDT - 1
    dd gdtStart
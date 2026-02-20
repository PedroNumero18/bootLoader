[BITS 16]
[ORG 0x9000]

main:
    ; --- Initialisation de l'environnement Stage 2 ---
    mov ax, 0x0000
    mov ds, ax          
    mov es, ax          
    mov ss, ax          
    mov sp, 0x8000      

    mov si, MSG_STAGE2
    call print16

    call enableA20

    call loadPM

    ; Ne doit jamais être atteint
    jmp $

MSG_STAGE2 db "[OK] Stage 2 active. Switching to Protected Mode...", 0x0A, 0x0D, 0

%include "gdt.asm"          
%include "a20.asm"          
%include "pm.asm"    
%include "print.asm"     

; --- Sauvegarde rapide des registres ---
    %macro PUSH_ALL 0
        pusha
        push ds
        push es
        push fs
        push gs
    %endmacro

; --- Restauration rapide des registres ---
    %macro POP_ALL 0
        pop gs
        pop fs
        pop es
        pop ds
        popa
    %endmacro

; --- Macro de debug pour QEMU ---
    %macro BOCHS_BREAK 0
        xchg bx, bx
    %endmacro

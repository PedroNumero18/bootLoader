enableA20:
    in al, 0x92
    and al, 0xFE 
    or al, 0x02   
    out 0x92, al
    ret

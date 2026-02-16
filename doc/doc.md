# The Boot Loader
## Boot Sequence
### Master Boot Record (MBR)
the boot signature containt the byte signature 0x55AA

#### real mode
memory access is handled using segmentation with 1 MB accessible memory in this format (segment: offset)   
we have a 16-bits segment address stored in a segment register (they are the starting point of a segment)  
- ``CS``: code segment   
- ``DS``: data segment  
- ``ES``: extra segment  
- ``SS``: stack segment  
- ``FS``: F segment  
- ``GS``: G segment  

and we also have 4 bits offset value stored in general purpose register (R1, R2 ...etc)
which means we have $2^{20}$ bits total (~1MB)

to calculate a physical address we can use this equation
$$PhisicalAddr = segment * 16 + offset$$

real mode is not secure and when the CPU run a programm it can impact the kernel and destroy it 

### Basic Input Output System (BIOS)
The bios offer some low level function that help the boot process
we can acces them via software interrupt 
here a some useful function  
- ``INT 0x10``: video display functions  
- ``INT 0x13``: mass storage (disk, floppy) access  
- ``INT 0x15``: memory size functions  
- ``INT 0x16``: keyboard functions   

for a simple ``Hello World!`` we use the function ``INT 0x10`` and put the value ``0xE`` in th ``AH`` register
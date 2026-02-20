# The Boot Loader

## Stage 1:
### Boot Sequence
#### Master Boot Record (MBR)
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

to calculate a physical address we can use this equation:
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

## Stage 2:
### Global Descriptor Table (GDT):
the GDT is data structure that define the characteristics of various memory segments  
exemple:

|      Addr      |    Content    |
|----------------|---------------|
| GDTR offset +0 |      NULL     |
| GDTR offset +8 |     ENTRY1    |
| GDTR offset +8 |     ENTRY2    |
| GDTR offset +8 |     ENTRY3    |
|      ...       |      ...      |
|                |               |

in each row we have an address which is GDTR + offset. GTDR is a register that hold the address to the beginning of the GDT  
Each entry in the table is a segment in the form of a segment descriptor structure 

#### Segment Descriptor
this data structure is 8 bytes long (basically it's a bit array) 

__Segment Descriptor general structure:__
|63<-------->56|55<------->52|51<-------->48|47--------------->40|39-<----->32|31<------->16|15<---------->0|
|--------------|-------------|--------------|--------------------|------------|-------------|---------------|
|Base (8bits)  |Flags (4bits)|Limit (4bits) |Access Byte (8bits) |Base (8bits)|Base (16bits)|Limit (16bits) |
|              |             |              |                    |            |             |               |

- ``Base`` contain the linear address where the segment begins.
- ``Limit`` tells the maximum address unit(size of the segment)

#### Access Byte:
The Access Byte is another structure by itself starting

| 7 |6   5| 4 | 3 |  2 |  1 | 0 |
|---|-----|---|---|----|----|---|
| P | DPL | S | E | DC | RW | A |
|   |     |   |   |    |    |   |

- ``P``: Present bit, it indicate if segment is present in memory, Value: ``1``: True ``0``     : False
- ``DPL``: Descriptor Privilege Level, indicate the CPU privilege level of the segment, Value: ``00``: Kernel, ``01``: Advance Devices Driver, ``10``: Devices Driver, ``11``: User Space
- ``S``: Descriptor type bit, Value :``0``     : system segment, ``1``: code or data segment
- ``E``: Executable bit, Value: ``0`` : data segment, ``1``: code segment
- ``DC``: Direction bit (E = 0): Direction bit control how the data segment grow, Value: ``0`` : the segment grow up, ``1``: the segment grow down
- ``DC``: Conforming bit (E = 1): Conforming bit control who can execute the code,  Value: ``0`` : only executed from the same privilege level ``1``: executed from lower privilege
- ``RW``: Writable bit (E = 0): control if we can write in this segment, Value: ``0`` : Read Only (if we write we generate a General Protection Fault), ``1``: Read and Write
- ``RW``: Readable bit (E = 1): controle if we can read this segment as data, Value: ``0``     : Executable Only, ``1``: Executable and Readable
- ``A``: Accessed bit : When the CPU access the segment, Value: ``1``: The Cpu accessed this segment at least one time, 0: Default

#### Flags:
| 3 |  2 | 1 |     0    |
|---|----|---|----------|
| G | DB | L | Reserved |
|   |    |   |          |

- ``G``: Granularity, define the unit of the Limit, Value: 0: size in bytes block(Max size = 1MB), 1: size in pages(4KiB)(Max size = 4GiB)
- ``DB``: Default operation size (the name (only the name)change if date or code segment), define the size of the operators, Value: 0: operators in 16-bits(legacy), 1: operators in 32-bits
- ``L``: Long Mode, indicate if the segment can run in 64-bits Value: 0: 32-bits or 16-bits depend on __DB__, 1: 64-bits and __DB__ is set at 0 
- ``Reserved``: always at 0 for intel new features

### Protected Mode:
Protected Mode is the main operating mode for 32-bits processor and it allow access up to 4 GiB of addressable memory  
It also enables operating system to introduce various protection mechanisms for exemple privilege levels.

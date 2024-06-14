.section .text

    .global _start

_start:    
    call menu           
    
    pushl %eax
    popl %eax
    movl $1, %eax       # sys call exit
    int $0x80

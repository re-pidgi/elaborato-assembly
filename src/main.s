.section .data

too_many_args_msg: .string "troppi parametri"
too_many_args_len: .long - too_many_args_msg

no_filename_msg: .string "nessun file specificato"
no_filename_len: .long - no_filename_msg

number_array: .fill 40

.section .text
    .global _start
    .global panic

_start:    
    # salva il puntatore allo stack
    movl %esp, %ebp

    # quanti parametri ci sono?
    movl (%esp), %eax

    # se non sono 2 o 3 panica
    cmp $2, %eax
    jb no_filename
    cmp $3, %eax
    ja too_many_args

    # prossimo valore sullo stack
    # assicurato per i controlli sopra
    addl $4, %esp
    # leggo il file che mi sta dando
    movl %esp, %ebx
    leal number_array, %edi
    call read_file

    
















    call menu        
    
    pushl %eax
    popl %eax
    movl $1, %eax       # sys call exit
    int $0x80


too_many_args:
    movl $4, %eax
    movl $1, %ebx
    leal too_many_args_msg, %ecx
    movl too_many_args_len, %edx
    int $0x80
    jmp panic

no_filename:
    movl $4, %eax
    movl $1, %ebx
    leal no_filename_msg, %ecx
    movl no_filename_len, %edx
    int $0x80

panic:
    # syscall exit (1)
    mov $1, %eax
    mov $1, %ebx
    int $0x80

exit:
    # syscall exit (0)
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80


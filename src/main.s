.section .data

too_many_args_msg: .string "troppi parametri\n"
too_many_args_len: .long . - too_many_args_msg

no_filename_msg: .string "nessun file specificato\n"
no_filename_len: .long . - no_filename_msg

bad_nums_count_msg: .string "quantita' di numeri errata"
bad_nums_count_len: .long . - bad_nums_count_msg


number_array: .fill 40

len: .int 0

.global len

.section .text
    .global _start
    .global panic
    .global exit

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
    addl $8, %esp
    # leggo il file che mi sta dando
    # (ebx: *filename, edi: *num_array) -> [
    #   eax: ret_type (0 normale, -X errore lettura)
    #   bl: last_char_read
    #   exc: char_read_qty
    #   edx: nums_converted ]
    movl (%esp), %ebx
    leal number_array, %edi
    call read_file

    # controlla che siano multipli di 4
    movl %edx, %ecx
    andl $3, %edx
    cmp $0, %edx
    jne bad_nums_count

    # diviso 4 e salvo
    shr $2, %ecx
    movl %ecx, len

sort_selection:
    # input del selettore
    # () -> [ al: selettore (0: scadenza, 1: priorità) ]
    call menu

    # <len>(al: selettore, edi: *number_array) -> [  ]
    call order

    # TODO calcoli
    nop

    jmp sort_selection

bad_nums_count:
    movl $4, %eax
    movl $1, %ebx
    leal bad_nums_count_msg, %ecx
    movl bad_nums_count_len, %edx
    int $0x80
    jmp panic

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


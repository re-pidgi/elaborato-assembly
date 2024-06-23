.section .data

number_array: .fill 40

output_array: .fill 40

len: .int 0
.global len

choice: .byte 0
.global choice

output_file_name: .int 0
.global output_file_name

.section .text
    .global _start
    .global panic
    .global exit

_start:    
    # salva il puntatore allo stack
    movl %esp, %ebp

    # quanti parametri ci sono?
    movl (%esp), %eax

    # se non sono 2 o 3 manda a errore
    cmp $2, %eax
    jb err_no_filename
    cmp $2, %eax
    je no_output_file
    cmp $3, %eax
    ja err_too_many_args

    addl $12, %esp
    movl (%esp), %eax
    movl %eax, output_file_name
    subl $12, %esp

no_output_file:
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
    jne err_bad_nums_count

    # divido per 4 la quantità di numeri e salvo la lunghezza
    shr $2, %ecx
    movl %ecx, len

sort_selection:
    # input del selettore
    # () -> [ al: selettore (0: scadenza, 1: priorità) ]
    call menu
    movb %al, choice

    leal number_array, %edi
    # <len>(al: selettore, edi: *number_array) -> [  ]
    call order

    # TODO calcoli

    # moltiplico len * 4 perché non posso fare
    # indirizzamento indicizzato con moltiplicatore
    # perché uso tutti i registri per altre cose
    # vagamente più necessarie
    movl len, %eax
    shl $2, %eax
    movl %eax, len

    xor %ecx, %ecx
    xor %eax, %eax
    xor %ebx, %ebx
    xor %edx, %edx
    xor %esi, %esi
    xor %edi, %edi
    # eax calcolo penalità
    # ebx oggetto corrente
    # ecx index all'array
    # edx formato output (ID:INIZIO)
    # esi tempo corrente
    # edi somma penalità

for_each_product:
    # se ho già fatto tutti gli elementi
    movl len, %eax
    cmpb %cl, %al
    je for_each_product_exit

    # carica il prodotto in ebx
    mov number_array(%ecx), %ebx

    # sposta l'ID e copia INIZIO in edx
    # salva nell'array per gli output
    mov %si, %dx
    rorl $16, %edx
    movb %bl, %dl
    xor %bl, %bl
    mov %edx, output_array(%ecx)

    # TIME in bl e SCAD in bh
    rorl $8, %ebx

    # aggiungi TIME al TOTTIME e cancella bl
    mov %bl, %al
    add %ax, %si
    xor %bl, %bl

    # SCAD in bx
    rorw $8, %bx

    # compara TOTTIME con SCAD
    cmp %si, %bx
    # se è SCAD minore di TOTTIME calcola penale
    # ergo se SCAD maggiore o uguale salta il calcolo
    jae no_penalty

    # sposta in TOTTIME in ax
    mov %si, %ax
    # calcola il DELTATIME
    sub %bx, %ax
    # moltiplicalo per PRIORITY
    rorl $16, %ebx
    mul %bx
    # aggiungi la penale a TOTPENALTY
    rorl $16, %edx
    mov %ax, %dx
    add %edx, %edi

no_penalty:
    # vai al prossimo elemento
    # guarda sopra come mai non posso usare incl %ecx
    addl $4, %ecx

    jmp for_each_product

for_each_product_exit:
    movl len, %eax
    shr $2, %eax
    movl %eax, len

    xorl %ebx, %ebx

    # TODO PRINT
    movw %di, %bx
    roll $16, %ebx 
    movw %si, %bx

    leal output_array, %esi
    call print_report

    jmp sort_selection

exit:
    # syscall exit (0)
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80


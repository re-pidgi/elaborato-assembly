.section .data

edf_order_msg: .string "Pianificazione EDF:\n"
edf_order_len: .int . - edf_order_msg

hpf_order_msg: .string "Pianificazione HPF:\n"
hpf_order_len: .int . - hpf_order_msg

ending_time_msg: .string "Conclusione: "
ending_time_len: .int . - ending_time_msg

penalty_msg: .string "Penalty: "
penalty_len: .int . - penalty_msg

buf_len: .int 0

.section .text
    .global print_report

.type print_report, @function

# (al: selettore, ebx: tot_penalty + tot_time, esi: output_array) -> []
print_report:
    # eax dati da stampare
    # ebx minibuffertorevert
    # ecx index
    # edx charcount
    # esi *output_array
    # edi *buffer

    # utilizzo fd (fino ad ora inutilizzato) per salvare altri dati
    movl %ebx, fd

    # resetta i counter e carica il buffer (esi è già impostato)
    xor %edx, %edx
    leal buffer, %edi

    # in base alla scelta di algoritmo stampa la stringa giusta
    movb choice, %al
    cmp $0, %al
    jne load_hpf_intro

    leal edf_order_msg, %ebx
    movl edf_order_len, %ecx

load_hpf_intro:
    leal hpf_order_msg, %ebx
    movl hpf_order_len, %ecx

print_intro:
    call copy_bytes

    # minibuffer
    xor %ebx, %ebx
    # counter per numero di prodotti
    xor %ecx, %ecx

    # per ogni prodotto
product_order_print_loop:
	# se ho finito i prodotti esco
    movl len, %eax
    cmpb %cl, %al
    jbe product_order_print_exit

    # carica dati dall'array in eax
    movl (%esi, %ecx, 4), %eax

    # trasforma e stampa il numero in ax (ID)
    call append_int_to_buf

    # stampa ':'
    movl $58, (%edi, %edx, 1)
    incl %edx

    # trasforma e stampa il numero in ax (INIZIO)
    roll $16, %eax
    call append_int_to_buf

    # stampa '\n'
    movl $10, (%edi, %edx, 1)
    incl %edx

    # prossimo prodotto
    incl %ecx
    jmp product_order_print_loop

product_order_print_exit:
    # stampa conclusione
    leal ending_time_msg, %ebx
    movl ending_time_len, %ecx
    call copy_bytes

    # stampa TOTTIME
    movl fd, %eax
    call append_int_to_buf

    # stampa '\n'
    movl $10, (%edi, %edx, 1)
    incl %edx

    # stampa penalità 
    leal penalty_msg, %ebx
    movl penalty_len, %ecx
    call copy_bytes

    # stampa TOTPENALTY
    roll $16, %eax
    call append_int_to_buf

    # stampa '\n'
    movl $10, (%edi, %edx, 1)
    incl %edx

    # inserisci '\0' alla fine del buffer
    movl $0, (%edi, %edx, 1)

    # decidi dove stampare (file o stdout)

    # output attraverso stdin o file
    movl output_file_name, %eax
    cmpl $0, %eax
    je print_to_stdout

    # output con file

    # salva la lunghezza del buffer
    movl %edx, buf_len

    # print al file
    # apri il file
    movl %eax, %ebx
    movl $5, %eax
    movl $66, %ecx
    movl $0644, %edx
    int $0x80

    # salva fd
    movl %eax, fd

    # scrivi il buffer nel file
    movl $4, %eax
    movl fd, %ebx
    leal buffer, %ecx
    movl buf_len, %edx
    int $0x80

    # close file
    mov $6, %eax
    mov fd, %ebx
    int $0x80

    ret

print_to_stdout:
    # stampa
    movl $4, %eax
    movl $1, %ebx
    movl %edi, %ecx
    int $0x80

    ret

# aggiunge un numero caricato in ax al buffer all'indirizzo edi
# (ax: number, edi: *buffer) -> []
append_int_to_buf:
    xorb %ch, %ch # quanti caratteri ha questo numero (assicurato sempre < 4)
    xorl %ebx, %ebx # minibuffer per invertire (uso un registro buffer per poi invertire i caratteri)

int_to_str:
    # fai spazio nel minibuffer se c'è bisogno di aggiungere un digit
    # alla prima iterazione rimane 0x0
    shll $8, %ebx

    # calcola resto e trasformalo in carattere
    divb ten
    addb $48, %ah

    # aggiungi il carattere al minibuffer e aumenta di 1 i caratteri
    movb %ah, %bl
    incb %ch

    # togli il resto da ah che altrimenti la divisione fa esplodere tutto
    xorb %ah, %ah

    # se non è 0 allora rimani
    cmpb $0, %al
    jne int_to_str

    # carica i caratteri dove serve nel buffer
    movl %ebx, (%edi, %edx, 1)

    # aggiungi la quantità di digits a edx (passando per il registro libero ax perché altrimenti non si riesce)
    movb %ch, %al
    addw %ax, %dx
    # resetta ax e ch
    xorw %ax, %ax
    xorb %ch, %ch

    ret

# copia ecx bytes dalla stringa in ebx al buffer in edi a partire dalla posizione edx
# (ebx: *string, ecx: len, edx: offset, edi: *buffer) 
copy_bytes:
    decb %cl
    movb %cl, %ah
    xorb %cl, %cl
copy_byte_loop:
    cmpb %ah, %cl
    jae exit_copy_byte

    movb (%ebx, %ecx, 1), %al
    movb %al, (%edi, %edx, 1)
    incl %edx
    incb %cl

    jmp copy_byte_loop

exit_copy_byte:
    ret

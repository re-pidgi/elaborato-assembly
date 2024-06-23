.section .data

fd: .int 0
buffer: .fill 132 # len "ddd,dd,ddd,d\n" * 10 +EOF?+EOF
ten: .byte 10

edf_order_msg: .string "Pianificazione EDF:\n"
edf_order_len: .int . - edf_order_msg

hpf_order_msg: .string "Pianificazione HPF:\n"
hpf_order_len: .int . - hpf_order_msg

ending_time_msg: .string "Conclusione: "
ending_time_len: .int . - ending_time_msg

penalty_msg: .string "Penalty: "
penalty_len: .int . - penalty_msg

.section .text
.global read_file
.type read_file, @function
    # (ebx: *filename, edi: *number_array) -> [
    #   eax: ret_type (0 normale, -X errore lettura)
    #   bl: last_char_read
    #   exc: char_read_qty
    #   edx: nums_converted ]

.global print_report
.type print_report, @function
    # (ebx: tot_penalty + tot_time, esi: output_array) -> []

read_file:
    # TODO: SALVARE I REGISTRI SULLO STACK PERCHÉ BEST (only) PRACTICE 

    # syscall open(filename, readonly) -> [eax: fd] 
    mov $5, %eax
    # leal filename, %ebx
    mov $0, %ecx
    int $0x80

    # IF eax == (NULL | error) { return }
    cmp $0, %eax
    jl return

    # fd = eax
    mov %eax, fd

    # syscall read (fd, *buffer, len=1)
    mov $3, %eax
    mov fd, %ebx
    leal buffer, %ecx
    mov $131, %edx
    int $0x80

    # syscall close (fd)
    mov $6, %eax
    mov fd, %ebx
    int $0x80

    # c = 0, i = 0
    xor %ecx, %ecx
    xor %edx, %edx

    mov $0, %eax
    leal buffer, %esi

for_each_char:
    # bl = char[c]
    movb (%esi,%ecx,1), %bl
    # c += 1
    incl %ecx

    # IF bl == (',' | '\n' | EOF) { next_array_pos }
    # il 132esimo e' assicurato essere 0 perche' ne leggo 131
    cmpb $44, %bl
    je next_array_pos
    cmpb $10, %bl
    je next_array_pos
    cmpb $0, %bl
    je next_array_pos

    # IF (!bl.is_digit) { panic }
    sub $48, %bl
    cmpb $10, %bl
    jae err_expected_digit

    # al *= 10
    mulb ten
    addb %bl, %al

    jmp for_each_char

next_array_pos:
    cmp $40, %edx
    je err_too_many_nums

    # number[i] = al
    movb %al, (%edi,%edx,1)

    # reset eax
    xor %eax, %eax
    # i += 1
    incl %edx

    cmp $40, %edx
    je return
    cmp $0, %bl
    je return

    jmp for_each_char

return:
    ret



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

    xor %ebx, %ebx
    xor %ecx, %ecx

product_order_print_loop:
    movl len, %eax
    cmpb %cl, %al
    jbe product_order_print_exit

    # carica dati dall'array in eax
    movl (%esi, %ecx, 4), %eax

    # trasforma in int l'ID
    call append_int_to_buf

    roll $16, %eax
    movl $58, (%edi, %edx, 1)
    incl %edx

    # trasforma in int l'INIZIO
    call append_int_to_buf

    movl $10, (%edi, %edx, 1)
    incl %edx

    incl %ecx
    jmp product_order_print_loop

product_order_print_exit:
    # inserisci conclusione
    leal ending_time_msg, %ebx
    movl ending_time_len, %ecx
    call copy_bytes

    movl fd, %eax
    call append_int_to_buf

    # \n
    movl $10, (%edi, %edx, 1)
    incl %edx

    # inserisci penalità
    leal penalty_msg, %ebx
    movl penalty_len, %ecx
    call copy_bytes

    roll $16, %eax
    call append_int_to_buf

    # \n
    movl $10, (%edi, %edx, 1)
    incl %edx

    # output attraverso stdin o file
    movl output_file_name, %eax
    cmpl $0, %eax
    je print_to_stdout

    # print al file
    # syscall open(filename, readonly) -> [eax: fd]
    movl %eax, %ebx
    movl $5, %eax
    movl $4, %ecx
    int $0x80

    movl %eax, fd

    # write file
    movl %eax, %ebx
    movl $4, %eax
    movl fd, %ebx
    leal buffer, %ecx
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


# (ax: number, edi: *buffer) -> []
append_int_to_buf:
    xorb %ch, %ch # quanti caratteri ha questo numero
    xorl %ebx, %ebx # minibuffer per invertire

int_to_str:
    # fai spazio nel minibuffer se c'è bisogno di aggiungere un digit
    shll $8, %ebx

    # calcola resto e trasformalo in carattere
    divb ten
    addb $48, %ah

    # aggiungi il carattere a ebx e aumenta di 1 i caratteri
    movb %ah, %bl
    incb %ch

    # togli il resto da ah che altrimenti la divisione fa esplodere tutto
    xorb %ah, %ah

    cmpb $0, %al
    jne int_to_str

    # carica i caratteri dove serve nel buffer
    movl %ebx, (%edi, %edx, 1)

    # aggiungi la quantità di digits a edx
    movb %ch, %al
    addw %ax, %dx
    # resetta ax e ch
    xorw %ax, %ax
    xorb %ch, %ch

    ret


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

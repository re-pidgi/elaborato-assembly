.section .data

fd: .int 0
buffer: .fill 132 # len "ddd,dd,ddd,d\n" * 10 +EOF?+EOF
ten: .byte 10

.global fd
.global buffer
.global ten

.section .text

.global read_file
.type read_file, @function
    # (ebx: *filename, edi: *number_array) -> [
    #   eax: ret_type (0 normale, -X errore lettura)
    #   bl: last_char_read
    #   exc: char_read_qty
    #   edx: nums_converted ]

.global check_bounds
.type check_bounds, @function

.global print_report
.type print_report, @function
    # (ebx: tot_penalty + tot_time, esi: output_array) -> []

read_file:
    # TODO: SALVARE I REGISTRI SULLO STACK PERCHÉ BEST (only) PRACTICE 

    # syscall open(filename, readonly) -> [eax: fd] 
    mov $5, %eax
    # leal filename, %ebx
    mov $0, %ecx
    mov $0, %edx
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
    mov $133, %edx
    int $0x80

    # TODO uscrie dal programma se file torppo0 lungo

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

    # esci se >40 ma vuoi che non sia errore
    # cmp $40, %edx
    # je return

    # esci se byte letto è EOF
    cmp $0, %bl
    je return

    jmp for_each_char

return:
    ret



# (edi: *number_array, edx: len)
check_bounds:
    xorl %ecx, %ecx

check_bounds_loop:
    cmp %ecx, %edx
    jbe exit_check_bounds_loop

    movl (%edi, %ecx, 4), %eax

    cmp $0, %al
    je err_number_out_of_bounds
    cmp $127, %al
    ja err_number_out_of_bounds
    shr $8, %eax

    cmp $0, %al
    je err_number_out_of_bounds
    cmp $10, %al
    ja err_number_out_of_bounds
    shr $8, %eax
    
    cmp $0, %al
    je err_number_out_of_bounds
    cmp $100, %al
    ja err_number_out_of_bounds
    shr $8, %eax
    
    cmp $0, %al
    je err_number_out_of_bounds
    cmp $5, %al
    ja err_number_out_of_bounds    

    incl %ecx

    jmp check_bounds_loop

exit_check_bounds_loop:
    ret

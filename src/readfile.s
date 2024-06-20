.section .data
#    .global number_array

#filename: .string "/home/pg/Documents/progettoassembly/elaborato-assembly/bin/ordini.txt"
fd: .int 0
buffer: .fill 132 # len "ddd,dd,ddd,d\n" * 10 +EOF?+EOF
#number_array: .fill 40
ten: .byte 10

expected_digit_msg: .string "il file contiene un carattere sconosciuto"
expected_digit_len: .long - expected_digit_msg

.section .text
.global read_file
.type read_file, @function
    # (ebx: *filename, edi: *num_array) -> [
    #   eax: ret_type (0 normale, -X errore lettura)
    #   bl: last_char_read
    #   exc: char_read_qty
    #   edx: nums_converted ]

read_file:
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
    jae expected_digit

    # al *= 10
    mulb ten
    addb %bl, %al

    jmp for_each_char

next_array_pos:
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

expected_digit:
    movl $4, %eax
    movl $1, %ebx
    leal expected_digit_msg, %ecx
    movl expected_digit_len, %edx
    int $0x80

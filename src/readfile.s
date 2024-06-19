.section .data
    .global number_array

filename: .string "/home/pg/Documents/progettoassembly/elaborato-assembly/bin/ordini.txt"
fd: .int 0
buffer: .fill 132 # len "ddd,dd,ddd,d\n" * 10 +EOF?+EOF
number_array: .fill 40
ten: .byte 10

.section .text
    .global _start

_start:
    # syscall open(filename, readonly) -> [eax: fd] 
    mov $5, %eax
    leal filename, %ebx
    mov $0, %ecx
    int $0x80

    # IF eax == (NULL | error) { exit }
    cmp $0, %eax
    jl _exit

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
    leal number_array, %edi

_for_each_char:
    # bl = char[c]
    movb (%esi,%ecx,1), %bl
    # c += 1
    incl %ecx

    # IF bl == (',' | '\n' | EOF) { next_array_pos }
    # il 132esimo e' assicurato essere 0 perche' ne leggo 131
    cmpb $44, %bl
    je _next_array_pos
    cmpb $10, %bl
    je _next_array_pos
    cmpb $0, %bl
    je _next_array_pos

    # IF (!bl.is_digit) { panic }
    sub $48, %bl
    cmpb $10, %bl
    jge _panic

    # al *= 10
    mulb ten
    addb %bl, %al

    jmp _for_each_char

_next_array_pos:
    # number[i] = al
    movb %al, (%edi,%edx,1)

    cmp $40, %edx
    je _exit
    cmp $0, %bl
    je _exit

    # reset eax
    mov $0, %eax
    # i += 1
    incl %edx

    jmp _for_each_char


_exit:
    # syscall exit (0)
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80

_panic:
    # syscall exit (1)
    mov $1, %eax
    mov $1, %ebx
    int $0x80


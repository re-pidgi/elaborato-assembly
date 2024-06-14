.section .data

filename: .string "ordini.txt"
fd: .int 0
buffer: .byte 0

number_index: .int 0
number_index_max: .int 40 // max 40 numeri (10 prod * 4 campi)
number_array: .fill 40 // 40 byte

.section .text
    .global _start

_open:
    // SYSCALL open (filename, readonly) -> [eax: fd] 
    mov $5, %eax
    mov $filename, %ebx
    mov $0, %ecx
    int $0x80

    // if eax == NULL { exit }
    cmp $0, %eax
    jl _exit

    // fd = eax
    mov %eax, fd

    // number_index = 0
    mov $0, number_index

_read_char_loop:
    // SYSCALL read (fd, *buffer, len=1)
    mov $3, %eax
    mov fd, %ebx
    mov $buffer, %ecx
    mov $1, %edx
    int $0x80

    // if (len_bytes <= 1) { _close_file }
    cmp $0, %eax
    jle _close_file     // Se ci sono errori o EOF, chiudo il file

    // if (buffer == '\n' | buffer == ',') { numbe_index += 1 }
    movb buffer, %al
    cmpb $10, %al
    jne _check_digit
    cmpb $44, %al
    jne _check_digit

    inc number_index

    // else { _check_digit }
_check_digit:
    // if (!buffer.is_digit) { panic }
    sub $48, %al
    cmpb $10, %al
    jge _panic

    // array[index] *= 10
    mov number_index, %ebx
    movb number_array(%ebx,1), %cl
    imul $10, %cl
    add %al, %cl
    movb %cl, number_array(%ebx,1)

    jmp _read_char_loop

_close_file:
    // SYSCALL close (fd)
    mov $6, %eax
    mov fd, %ebx
    int $0x80

_exit:
    // SYSCALL exit (0)
    mov $1, %eax
    xor %ebx, %ebx
    int $0x80


_panic:
    // SYSCALL close (fd)
    mov $6, %eax
    mov fd, %ebx
    int $0x80

    // SYSCALL exit (1)
    mov $1, %eax
    mov $1, %ebx
    int $0x80

_start:
    jmp _open
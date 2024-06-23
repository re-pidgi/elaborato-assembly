.section .data

too_many_args_msg: .string "troppi parametri\n"
too_many_args_len: .int . - too_many_args_msg

no_filename_msg: .string "nessun file specificato\n"
no_filename_len: .int . - no_filename_msg

bad_nums_count_msg: .string "quantita' di numeri errata"
bad_nums_count_len: .int . - bad_nums_count_msg

expected_digit_msg: .string "il file contiene un carattere sconosciuto\n"
expected_digit_len: .int . - expected_digit_msg

too_many_nums_msg: .string "il file contiene troppi numeri\n"
too_many_nums_len: .int . - expected_digit_msg

.section .text
	.global panic
	.global err_too_many_args
	.global err_no_filename
	.global err_bad_nums_count
	.global err_expected_digit
	.global err_too_many_nums


err_bad_nums_count:
    leal bad_nums_count_msg, %ecx
    movl bad_nums_count_len, %edx
    jmp print_error

err_too_many_args:
    leal too_many_args_msg, %ecx
    movl too_many_args_len, %edx
    jmp print_error

err_no_filename:
    leal no_filename_msg, %ecx
    movl no_filename_len, %edx
    jmp print_error

err_too_many_nums:
    leal too_many_nums_msg, %ecx
    movl too_many_nums_len, %edx
    jmp print_error

err_expected_digit:
    leal expected_digit_msg, %ecx
    movl expected_digit_len, %edx
    jmp print_error

print_error:
    movl $4, %eax
    movl $1, %ebx
    int $0x80

panic:
    # syscall exit (1)
    mov $1, %eax
    mov $1, %ebx
    int $0x80



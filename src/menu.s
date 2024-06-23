.section .data

menu_prompt: .ascii "decidi l'ordine da usare. (1: EDF (scadenza), 2: HPF (priorità), altro: EXIT): " 
menu_prompt_len: .long . - menu_prompt

choice_buffer: .fill 10

.section .text
    .global menu

.type menu, @function
    # () -> [ al: selettore (0: scadenza, 1: priorità) ]

menu:
    # stampa del prompt
    movl $4, %eax
    movl $1, %ebx
    leal menu_prompt, %ecx
    movl menu_prompt_len, %edx
    int $0x80

    # input di due caratteri
    movl $3, %eax
    movl $0, %ebx
    leal choice_buffer, %ecx
    movl $10, %edx
    int $0x80 

    # controlla che sia un solo carattere + newline

    # controlla se è altro rispetto a "1\n" o "2\n"
    movw choice_buffer, %ax
    cmp $10, %ah
    jne exit
    cmp $49, %al
    jb exit
    cmp $50, %al
    ja exit

    xorb %ah, %ah

    # converti "1" o "2" a 0 o 1
    sub $49, %al

    ret

.section .data

menu_prompt: .ascii "decidi l'ordine da usare. (1: EDF (scadenza), 2: HPF (priorità), altro: EXIT):" 
menu_prompt_len: .long . - menu_prompt

choice_buffer: .byte 0

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

    # input carattere
    movl $3, %eax
    movl $0, %ebx
    leal choice_buffer, %ecx
    movl $1, %edx
    int $0x80 

    # controlla se è altro rispetto a 1 o 2
    movb choice_buffer, %al
    cmp $49, %al
    jb exit
    cmp $50, %al
    ja exit

    # converti a 0 o 1
    sub $49, %al

    ret

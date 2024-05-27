
.section .data                 

menu_prompt:
      .ascii "decidi l'ordine da usare. (1: EDF (scadenza), 2: HPF (priorità), altro: EXIT)"

menu_prompt_len:
      .long . - menu_prompt

buffer:
      .byte 0

.section .text
      .global _menu_start

_menu_start:
      # PRINT menu_prompt
      movl $4, %eax
      movl $1, %ebx
      leal menu_prompt, %ecx
      movl hello_len, %edx
      int $0x80

      # READ char
      movl $3, %eax
      movl $0, %ebx
      leal buffer, %ecx
      movl $1, %edx
      int $0x80

      # MOVE char
      xor %eax, %eax
      mov buffer, %al
      
      # IF char == '1'
      movl $49, %ebx,
      cmp %eax, %ebx
      je equal_1 
      
      # IF char == '2'
      movl $50, %ebx,
      cmp %eax, %ebx
      je equal_2
      
      # ELSE EXIT
      movl $0, %eax
      movl $0, %ebx
      int $0x80

equal_1:
      movl $1, %eax
      ret

equal_2:
      movl $2, %eax
      ret
.section .data                 

menu_prompt:
    .ascii "decidi l'ordine da usare. (1: EDF (scadenza), 2: HPF (priorità), altro: EXIT):" 

menu_prompt_len:
    .long . - menu_prompt

scelta:
	.ascii "00"
scelta_len:
	.long . - scelta 

num_int:
	.long 0

.section .text
    .global _start

_start:
stampa_richiesta:
    movl $4, %eax
    movl $1, %ebx
    leal menu_prompt, %ecx
    movl menu_prompt_len, %edx
    int $0x80

scanf:
    movl $3, %eax
    movl $1, %ebx
    leal scelta, %ecx
    movl scelta_len, %edx
    int $0x80 

converti:
	leal scelta, %esi 
	xorl %eax, %eax
	xorl %ebx, %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx

	movb (%ecx,%esi,1), %bl
	subb $48, %bl 
	movl $10, %edx 
	mulb %dl 
	addl %ebx, %eax

	movl %eax, num_int

fine:
	movl $1, %eax
	int $0x80

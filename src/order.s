.section .data 

.section .text
	.global order

.type order, @function

order:
	movl $4, %eax
    movl $1, %ebx
    leal menu_prompt, %ecx
    movl menu_prompt_len, %edx
    int $0x80
	
	ret 
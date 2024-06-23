.section .data 

.section .text
	.global order

.type order, @function
    # (al: selettore, dl: len, edi: *number_array) -> [  ]

.type sort, @function

.type reverse, @function

.type rotate_by, @function

order:
	# selettore algoritmo (0: scadenza, 1: priorità)
	cmp $0, %al
	jne order_by_priority

	xorl %ecx, %ecx


	# sort utilizza %al come chiave di sorting per due elementi
	# usiamo rotate_by (ror su tutti gli elementi) per
	# utilizzare la chiave che vogliamo senza perdere dati

	# bisogna stare attenti a little/big-endian
	# quando carico un prodotto in un registro
	# la priorità è nel bit più significativo del registro

	# ORDINE PER SCADENZA
	# 1. ordina prima per priorità
	# 2. inverti la lista (viene prima quella col valore più alto)
	# 3. ordina per scadenza
	# funziona perché bubblesort è stabile
	movl $8, %ecx
	call rotate_by
	call sort

	call reverse

	movb $8, %cl
	call rotate_by
	call sort

	movb $16, %cl
	call rotate_by

	ret

order_by_priority:
	# ORDINE PER PRIORITA'
	# 1. ordina prima per scadenza
	# 2. inverti la lista
	# 3. ordina per priorità
	# 4. inverti la lista
	# funziona perché bubblesort è stabile
	movb $16, %cl
	call rotate_by
	call sort

	call reverse

	movb $24, %cl
	call rotate_by
	call sort

	call reverse

	movb $24, %cl
	call rotate_by

	ret

# <len> -> len
# edi: *number_array,
sort:
	decb len # n - 1
	xorl %edx, %edx # i = 0
outer_loop:
	# while i < n-1
	xorl %esi, %esi
	movl len, %esi
	cmpl %edx, %esi
	jbe exit_outer_loop

	subl %edx, %esi # n - i (- 1)
	xor %ecx, %ecx # j = 0

inner_loop:
	# while i < n (- i - 1)
	cmpl %ecx, %esi
	jbe exit_inner_loop

	# eax = arr[j]
	movl (%edi,%ecx,4), %eax
	# ebx = arr[j+1]
	incl %ecx
	movl (%edi,%ecx,4), %ebx

	cmpb %bl, %al
	jb dont_swap

	# swap
	# arr[j+1] = eax
	movl %eax, (%edi,%ecx,4)
	# arr[j] = ebx
	decl %ecx
	movl %ebx, (%edi,%ecx,4)
	incl %ecx

dont_swap:
	jmp inner_loop

exit_inner_loop:
	add $1, %edx
	jmp outer_loop

exit_outer_loop:
	incl len
	ret


# <len> -> len
# edi: *number_array,
reverse:
	xorl %ecx, %ecx 
	xorl %edx, %edx
	movl len, %edx
	subl $1, %edx

reverse_loop:
	cmpl %edx, %ecx
	jge exit_reverse_loop

	movl (%edi,%ecx,4), %eax
	movl (%edi,%edx,4), %ebx

	movl %eax, (%edi,%edx,4)
	movl %ebx, (%edi,%ecx,4)
	
	incl %ecx
	decl %edx

	jmp reverse_loop

exit_reverse_loop:
	ret

# <len> -> len
# edx: shifts_qty
# edi: *number_array
rotate_by:
	xorl %esi, %esi
	movl len, %esi

	xorl %edx, %edx

rotate_by_loop:
	cmpl %esi, %edx
	jae exit_rotate_by

	movl (%edi,%edx,4), %eax
	roll %cl, %eax
	movl %eax, (%edi,%edx,4)
	incl %edx
	jmp rotate_by_loop

exit_rotate_by:
	ret




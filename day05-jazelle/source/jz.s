.section .text

.align 4
.global do_jazelle
do_jazelle: @ Takes buffer for jazelle stuff in r0, bytecode address in r1, input arrays to pass to jazelle in r2 and r3
	push	{r4-r11, lr}

	mov	r5, r0                  @ Handler table pointer (must be 1024-byte aligned)
	add	r6, r5, #0x800          @ Stack pointer
	add	r7, r5, #0x900          @ Local variables pointer

	mov lr, r1

	@ Fill the entire instr table with that label, so we know if an unimplemented instr was encountered
	adr r0, unimpl_instr
	ldr r1, =(0x400 - 4)
fill_loop:
	str r0, [r5, r1]
	subs r1, #4
	bpl fill_loop
	
	@ Different handler for a few exceptions
	adr r0, null_ptr
	str r0, [r5, #0x400]
	adr r0, array_index
	str r0, [r5, #0x404]

	@ Set handler for ireturn bytecode
	adr	r0, ireturn
	str	r0, [r5, #0xAC * 4]
	
	mov r8, #0

	mov r0, r2
	mov r1, r3
	orr r5, #(2 << 2) @ There are two words in the stack in r0 and r1

	@ Execute the bytecode
	adr	r12, jazelle_unavailable
	bxj	r12

ireturn:
	@ Get result off the stack and return it
	ldr	r0, [r6, #-4]!
	pop	{r4-r11, pc}

jazelle_unavailable:
	mov	r0, #-1
	pop	{r4-r11, pc}

unimpl_instr:
	mov r0, #420
	pop	{r4-r11, pc}

null_ptr:
	mov r0, #69
	pop	{r4-r11, pc}

array_index:
	mov r0, #70
	pop	{r4-r11, pc}

.ltorg

.align 4
.global enable_jazelle_hardware
enable_jazelle_hardware:
	mov	r0, #2
	mcr	p14, 7, r0, c1, c0, 0
	mov	r0, #1
	orr r0, #(1 << 29) @ array objects contain their elements directly, or something
	mcr	p14, 7, r0, c2, c0, 0
	mov r0, #(1 << 8) @ the array data is 1 word from the start of the array
	mcr	p14, 7, r0, c3, c0, 0
	bx lr

/*.global get_thing
get_thing:
	mrc	p14, 7, r0, c3, c0, 0
	ldr r1, =thing
	str r0, [r1]
	bx lr*/

.ltorg

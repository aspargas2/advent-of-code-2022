.section .text

.global main
.type main, @function
main:

	addi $sp, $sp, -8
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	lw $s0, 4($a1) // argv[1]

	lui $a0, %hi(hello_world_string)
	addiu $a0, $a0, %lo(hello_world_string)
	jal printf

	add $t0, $zero, $s0
	addi $s0, $zero, 0
	addi $t2, $zero, 0
	addi $t5, $zero, 0
	addi $t6, $zero, 13
	lui $t8, %hi(part2_buffer)
	addiu $t8, $t8, %lo(part2_buffer)

main_loop:
	lb $t1, ($t0)
	addi $t0, $t0, 1
	addi $t5, $t5, 1
	beq $t1, $zero, main_problem // if we hit the null terminator, something went wrong
	sll $t2, $t2, 8
	or $t2, $t2, $t1
	add $t7, $t8, $t6
	sb $t1, ($t7)
	addi $t6, $t6, -1
	bgez $t6, skip_wrap
	addi $t6, $zero, 13
skip_wrap:
	
	// If we already got the answer to part1, skip it
	bnez $s0, part1_check_skip

	// If we haven't read 4 chars yet, can't have a match yet
	srl $t3, $t2, 24
	beq $t3, $zero, main_loop

	// Check if any of the 4 bytes of $t2 match each other
	add $t3, $zero, $t2
part1_check_loop:
	andi $t1, $t3, 0xFF
	srl $t3, $t3, 8
	beq $t3, $zero, part1_check_hit

	andi $t4, $t3, 0xFF
	beq $t1, $t4, main_loop
	srl $t4, $t3, 8
	andi $t4, $t4, 0xFF
	beq $t1, $t4, main_loop
	srl $t4, $t3, 16
	beq $t1, $t4, main_loop
	j part1_check_loop
part1_check_hit:
	add $s0, $zero, $t5
part1_check_skip:

	// If we haven't read 14 chars yet, can't have a part 2 match yet
	addi $t3, $t5, -14
	bltz $t3, main_loop

	addi $t3, $zero, 13
part2_outer_loop:
	add $t7, $t8, $t3
	lb $t1, ($t7)
	addi $t4, $t3, -1
part2_inner_loop:
	add $t7, $t8, $t4
	lb $t7, ($t7)
	beq $t7, $t1, main_loop
	addi $t4, $t4, -1
	bgez $t4, part2_inner_loop

	addi $t3, $t3, -1
	bgtz $t3, part2_outer_loop

main_break:
	lui $a0, %hi(part1_string)
	addiu $a0, $a0, %lo(part1_string)
	add $a1, $zero, $s0
	add $s0, $zero, $t5
	jal printf
	lui $a0, %hi(part2_string)
	addiu $a0, $a0, %lo(part2_string)
	add $a1, $zero, $s0
	jal printf

main_end:
	add $v0, $zero, $zero
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

main_problem:
	lui $a0, %hi(problem_string)
	addiu $a0, $a0, %lo(problem_string)
	add $a1, $zero, $t2
	jal printf
	j main_end


.section .bss

part2_buffer:
	.space 14

.section .rodata

hello_world_string:
	.ascii "bunny!\n\0"
part1_string:
	.ascii "Part 1: %u\n\0"
part2_string:
	.ascii "Part 2: %u\n\0"
problem_string:
	.ascii "Something went wrong t2: %X\n\0"
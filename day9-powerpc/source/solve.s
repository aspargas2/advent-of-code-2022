.section .text

#define FLAGS_DIM_BITS 9
#define FLAGS_DIM (1 << FLAGS_DIM_BITS)

.global solve
solve:
	//addi sp, sp, -4

	mr 8, 3
	lis 10, flags_mid@ha
	la 10, flags_mid@l(10)
	mr 9, 10

main_loop:
	lbz 3, 0(8)
	cmpi 7, 0, 3, 0
	beq 7, main_break
	lbz 4, 2(8)
	lbz 0, 3(8)
	cmpi 7, 0, 0, '\n'
	beq 7, not_two_digit
	// way too tired to write a proper atoi right now, please have mercy
	mr 4, 0
	subi 4, 4, '0'
	addi 4, 4, 10
	addi 8, 8, 5
	b two_digit_done
not_two_digit:
	addi 8, 8, 4
	subi 4, 4, '0'
two_digit_done:

	cmpi 7, 0, 3, 'U'
	beq 7, is_u
	cmpi 7, 0, 3, 'D'
	beq 7, is_d
	cmpi 7, 0, 3, 'L'
	beq 7, is_l
is_r:
	li 3, 1
	b dirs_done
is_l:
	li 3, -1
	b dirs_done
is_u:
	li 3, -FLAGS_DIM
	b dirs_done
is_d:
	li 3, FLAGS_DIM
dirs_done:

inner_loop:
	mr 7, 10
	add 10, 10, 3

	andi. 0, 10, FLAGS_DIM - 1
	andi. 5, 9, FLAGS_DIM - 1
	sub 5, 0, 5

	cmpi 7, 0, 5, -2
	beq 7, update_tail
	cmpi 7, 0, 5, 2
	beq 7, update_tail

	srwi 0, 10, FLAGS_DIM_BITS
	srwi 5, 9, FLAGS_DIM_BITS
	sub 5, 0, 5

	cmpi 7, 0, 5, -2
	beq 7, update_tail
	cmpi 7, 0, 5, 2
	beq 7, update_tail
	b update_tail_done

update_tail:
	mr 9, 7
update_tail_done:
	li 0, 1
	stb 0, 0(9)

	subi 4, 4, 1
	cmpi 7, 0, 4, 0
	bne 7, inner_loop

	b main_loop
main_break:

	lis 10, flags@ha
	la 10, flags@l(10)
	li 3, 0
	lis 5, (1 << ((FLAGS_DIM_BITS * 2) - 16))
	//li 5, 0xA
count_loop:
	lbz 0, 0(10)
	cmpi 7, 0, 0, 0
	beq 7, skip_inc_count
	addi 3, 3, 1
skip_inc_count:
	addi 10, 10, 1
	subi 5, 5, 1
	cmpi 7, 0, 5, 0
	bne 7, count_loop

	blr


.section .bss

.balign FLAGS_DIM
flags:
.skip (FLAGS_DIM * (FLAGS_DIM / 2)) + (FLAGS_DIM / 2), 0
flags_mid:
.skip (FLAGS_DIM * (FLAGS_DIM / 2)) - (FLAGS_DIM / 2), 0
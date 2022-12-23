.section .text

#define FLAGS_DIM_BITS 9
#define FLAGS_DIM (1 << FLAGS_DIM_BITS)

.global solve
solve:
	//addi sp, sp, -4

	mr 8, 3
	lis 10, flags_mid@ha
	la 10, flags_mid@l(10)
	lis 11, tails_arr@ha
	la 11, tails_arr@l(11)

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
	add 10, 10, 3
	mr 6, 10
	li 12, 0
tail_loop:
	add 9, 11, 12
	lwz 9, 0(9)

	andi. 0, 6, FLAGS_DIM - 1
	andi. 5, 9, FLAGS_DIM - 1
	sub 5, 0, 5

	srwi 0, 6, FLAGS_DIM_BITS
	srwi 7, 9, FLAGS_DIM_BITS
	sub 7, 0, 7

	cmpi 0, 0, 5, 2
	cmpi 1, 0, 5, -2
	cmpi 5, 0, 7, 2
	cmpi 6, 0, 7, -2

	// always not equal
	cmpi 7, 0, 11, 0

	beq 0, update_tail_xp2
	beq 1, update_tail_xm2
x2_ret:
	beq 5, update_tail_yp2
	beq 6, update_tail_ym2

	bne 7, tail_loop_break
	b update_tail

update_tail_xp2:
	subi 5, 5, 1
	cmp 7, 0, 5, 5
	b x2_ret
update_tail_xm2:
	addi 5, 5, 1
	cmp 7, 0, 5, 5
	b x2_ret
update_tail_yp2:
	subi 7, 7, 1
	b update_tail
update_tail_ym2:
	addi 7, 7, 1

update_tail:
	slwi 7, 7, FLAGS_DIM_BITS
	add 9, 9, 5
	add 9, 9, 7
	add 5, 11, 12
	stw 9, 0(5)
	mr 6, 9

	addi 12, 12, 4
	cmpi 7, 0, 12, (9*4)
	bne 7, tail_loop
tail_loop_break:

	lwz 9, 0(11)
	lbz 0, 0(9)
	ori 0, 0, 1
	stb 0, 0(9)

	lwz 9, (8*4)(11)
	lbz 0, 0(9)
	ori 0, 0, 2
	stb 0, 0(9)

	subi 4, 4, 1
	cmpi 7, 0, 4, 0
	bne 7, inner_loop

	b main_loop
main_break:

	lis 10, flags@ha
	la 10, flags@l(10)
	li 3, 0
	li 4, 0
	lis 5, (1 << ((FLAGS_DIM_BITS * 2) - 16))
	//li 5, 0xA
count_loop:
	lbz 0, 0(10)
	andi. 6, 0, 1
	beq 0, skip_inc_part1
	addi 3, 3, 1
skip_inc_part1:
	andi. 6, 0, 2
	beq 0, skip_inc_part2
	addi 4, 4, 1
skip_inc_part2:
	addi 10, 10, 1
	subi 5, 5, 1
	cmpi 7, 0, 5, 0
	bne 7, count_loop

	blr


.section .data

.balign 4
tails_arr:
.rept 9
.long flags_mid
.endr

.section .bss

.balign FLAGS_DIM
flags:
.skip (FLAGS_DIM * (FLAGS_DIM / 2)) + (FLAGS_DIM / 2), 0
flags_mid:
.skip (FLAGS_DIM * (FLAGS_DIM / 2)) - (FLAGS_DIM / 2), 0
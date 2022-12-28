#include <regdef.h>
#include <sys/asm.h>
#include <sys/syscall.h>

#define MAX_DEPTH 64
#define PART1_TARGET_SIZE 100000
#define PART2_NEEDED_SIZE (70000000 - 30000000)

.section .text

.balign 4
.global __start
__start:

	.set noreorder

	lw   s0, 8(sp) // argv[1] (sp+0 is argc)

	addi a0, zero, 1 // stdout
	lui  a1, %hi(hello_world_string)
	ori  a1, a1, %lo(hello_world_string)
	addi a2, zero, (hello_world_end - hello_world_string)
	addi v0, zero, __NR_write
	syscall

	add  s4, zero, zero // Will be set to non-zero when it's time for part 2; stores minimum needed size
do_it_again:
	lui  s3, %hi(dir_sizes)
	ori  s3, s3, %lo(dir_sizes)
	add  s1, zero, zero // Part 1 sum
	addi s2, zero, -1 // Tracks smallest found size for part 2
	srl  s2, s2, 1 // Set to signed max
main_loop:
	lb   t0, 0(s0)
	beq  t0, zero, main_break
	addi t0, -'\n'
	beq  t0, zero, main_break
	nop
	lb   t1, 2(s0)
	jal skip_line
	lb   t2, 5(s0)
	addi t1, t1, -'c'
	beq  t1, zero, cd_cmd
	nop
ls_loop:
	lb   t0, 0(s0)
	addi t0, t0, -'d'
	beq  t0, zero, dir_entry
	nop
	jal atoi
	add  t2, zero, s0
	beq  s0, t2, main_loop
	nop
	lw   t0, 0(s3)
	add  t0, t0, v0
	sw   t0, 0(s3)
dir_entry:
	jal skip_line
	nop
	j ls_loop
	nop
cd_cmd:
	addi t2, t2, -'.'
	beq  t2, zero, cd_dotdot
	nop
	addi s3, s3, 4
	j main_loop
	sw   zero, 0(s3)
cd_dotdot:
	addi s3, s3, -4
	lw   t0, 4(s3)
	lw   t2, 0(s3)
	lui  t1, (PART1_TARGET_SIZE >> 16)
	ori  t1, t1, (PART1_TARGET_SIZE & 0xFFFF)
	sub  t1, t0, t1
	beq  s4, zero, not_part2_dotdot
	nop
	sub  t4, t0, s4
	bltz t4, not_part2_dotdot
	sub  t4, s2, t0
	blez t4, not_part2_dotdot
	nop
	add  s2, zero, t0
not_part2_dotdot:
	add  t2, t0, t2
	bgtz t1, main_loop
	sw   t2, 0(s3)
	j main_loop
	add  s1, s1, t0
main_break:

	lui  t8, %hi(dir_sizes)
	ori  t8, t8, %lo(dir_sizes)
finish_loop:
	beq  s3, t8, finish_break
	nop
	addi s3, s3, -4
	lw   t0, 4(s3)
	lw   t2, 0(s3)
	lui  t1, (PART1_TARGET_SIZE >> 16)
	ori  t1, t1, (PART1_TARGET_SIZE & 0xFFFF)
	sub  t1, t0, t1
	beq  s4, zero, not_part2_finish
	nop
	sub  t4, t0, s4
	bltz t4, not_part2_finish
	sub  t4, s2, t0
	blez t4, not_part2_finish
	nop
	add  s2, zero, t0
not_part2_finish:
	add  t2, t0, t2
	bgtz t1, finish_loop
	sw   t2, 0(s3)
	j finish_loop
	add  s1, s1, t0
finish_break:

	bne  s4, zero, part2_done
	nop
	lw   s4, 0(s3)
	lui  t0, (PART2_NEEDED_SIZE >> 16)
	ori  t0, t0, (PART2_NEEDED_SIZE & 0xFFFF)
	sub  s4, s4, t0
	j do_it_again
	lw   s0, 8(sp)
part2_done:

	addi a0, zero, 1 // stdout
	lui  a1, %hi(part1_string)
	ori  a1, a1, %lo(part1_string)
	addi a2, zero, (part1_end - part1_string)
	addi v0, zero, __NR_write
	syscall

	add  a0, zero, s1
	lui  a1, %hi(str_buf_end)
	jal itoa
	ori  a1, a1, %lo(str_buf_end)

	addi a0, zero, 1
	add  a2, zero, v0
	addi v0, zero, __NR_write
	syscall

	lui  a1, %hi(part2_string)
	ori  a1, a1, %lo(part2_string)
	addi a2, zero, (part2_end - part2_string)
	addi v0, zero, __NR_write
	syscall

	add  a0, zero, s2
	lui  a1, %hi(str_buf_end)
	jal itoa
	ori  a1, a1, %lo(str_buf_end)

	addi a0, zero, 1
	add  a2, zero, v0
	addi v0, zero, __NR_write
	syscall

	lui  a1, %hi(newline)
	ori  a1, a1, %lo(newline)
	addi a2, zero, 1
	addi v0, zero, __NR_write
	syscall

.align 4
quit:
	addi a0, zero, 0
	addi v0, zero, __NR_exit
	syscall

	j quit
	nop


// Advances s0 past the next newline, clobbers t0
skip_line:
	lb   t0, 0(s0)
	beq  t0, zero, skip_line_break
	addi t0, t0, -'\n'
	bne  t0, zero, skip_line
skip_line_break:
	addi s0, s0, 1
	jr ra
	nop


// Does not follow ABI; input ptr in s0, returns in v0, advances s0 to first non-decimal found, clobbers t0, t1
atoi:
	add  v0, zero, zero
atoi_loop:
	lb   t0, 0(s0)
	addi t1, t0, -'9'
	bgtz t1, atoi_break
	addi t1, t0, -'0'
	bltz t1, atoi_break
	addi t0, zero, 10
	mult t0, v0
	mflo v0
	add  v0, v0, t1
	j atoi_loop
	addi s0, s0, 1
atoi_break:
	jr ra
	nop

// Number in a0, end of an out buf in a1, returns length in v0 and mutates a1 to point to the start of what was written to the buf, clobbers t0
itoa:
	add  v0, zero, zero
itoa_loop:
	addi a1, a1, -1
	addi v0, v0, 1
	addi t0, zero, 10
	div  a0, t0
	mflo a0
	mfhi t0
	addi t0, t0, '0'
	bne  a0, zero, itoa_loop
	sb   t0, 0(a1)
	jr ra
	nop

// Stops on first null or newline; clobbers t0, t1, t2
hash_str:
	add  v0, zero, zero
	add  t2, zero, zero
hash_loop:
	lb   t0, 0(a0)
	beq  t0, zero, hash_break
	addi t1, t0, -'\n'
	beq  t1, zero, hash_break
	sllv t0, t0, t2 // t2 will be 8 or 0
	xor  v0, v0, t0
	xori t2, t2, 8 // switch t2
	j hash_loop
	addi a0, a0, 1
hash_break:
	jr ra
	nop
/*
// clobbers t0, t1, t2
hash_table_set_bit:
	lui  t1, %hi(hash_table)
	ori  t1, t1, %lo(hash_table)
	srl  t0, a0, 3
	add  t0, t1, t0
	lb   t2, 0(t0)
	andi a0, a0, 7
	addi t1, zero, 1
	sllv t1, t1, a0
	or   t2, t2, t1
	jr ra
	sb   t2, 0(t0)

// clobbers t0, t1, t2
hash_table_get_bit:
	lui  t1, %hi(hash_table)
	ori  t1, t1, %lo(hash_table)
	srl  t0, a0, 3
	add  t0, t1, t0
	lb   t2, 0(t0)
	andi a0, a0, 7
	srlv t2, t2, a0
	jr ra
	andi v0, t2, 1*/

.section .bss

dir_sizes:
	.skip MAX_DEPTH * 4
cur_path:
	.skip MAX_DEPTH * 20
str_buf:
	.skip 10; str_buf_end:
//hash_table:
//	.skip (1 << (16 - 3))

.section .rodata

hello_world_string:
	.ascii "BEEG bunny"; newline: .ascii "\n"; hello_world_end:
part1_string:
	.ascii "Part 1: "; part1_end:
part2_string:
	.ascii "\nPart 2: "; part2_end:

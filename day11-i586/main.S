.intel_syntax noprefix

#include "monkey.h"

.section .text

//Layout of a monkey struct is
// 0:  operation type (0 for add literal, 1 for mul literal, 2 for old * old)
// 4:  literal operand, ignored for type 2
// 8:  test divisor
// 12: target if true
// 16: target if false
// 20: total number of items inspected
// 24: current number of items
// 28: array of item worry levels for part 1
// 156: array of item infos, MAX_MONKEYS bytes each, storing the remainder mod each monkey divisor

.global _start
_start:
	push offset hello_world_string
	call puts
	add esp, 4

	pop eax // argc
	cmp eax, 2
	je args_correct
	mov eax, 0[esp] // argv[0]
	push eax
	push offset args_wrong_string
	call printf
	add esp, 8
	call exit
args_correct:

	push ebx
	push edi
	push esi
	push ebp

	mov eax, 20
	push eax // number of rounds to count; tracks part1 vs part2

do_it_again:
	mov ebp, 24[esp] // argv[1], the puzzle input. what's a base pointer? :p
	xor edx, edx // monkey counter

process_input_loop:
	imul edi, edx, MONKEY_SIZE
	add edi, offset monkey_array // current monkey pointer
	inc edx
	add ebp, 28 // skip "Monkey X:\n  Starting items: "
	xor ecx, ecx
	mov [edi+20], ecx
starting_items_loop:
	call atoi
	mov [edi+28+ecx*4], eax
	mov al, [ebp]
	inc ecx
	add ebp, 2 // skip ", "
	cmp al, ','
	je starting_items_loop
starting_items_break:
	mov [edi+24], ecx // store number of items
	add ebp, 22 // skip " Operation: new = old "
	mov al, [ebp]
	add ebp, 2
	xor ecx, ecx
	cmp al, '*'
	jne imm_op
	inc ecx
	cmp byte ptr [ebp], 'o'
	jne imm_op
// old * old case
	inc ecx
	add ebp, 3 // skip "old"
	jmp skip_imm_op
imm_op:
	call atoi
	mov [edi+4], eax // store immediate operand
skip_imm_op:
	mov [edi], ecx // store operand type
	add ebp, 22 // skip "\n  Test: divisible by "
	call atoi
	mov [edi+8], eax // store divisor
	add ebp, 30 // skip "\n    If true: throw to monkey "
	call atoi
	mov [edi+12], eax
	add ebp, 31 // skip "\n    If false: throw to monkey "
	call atoi
	mov [edi+16], eax
// check for end of input
	cmp byte ptr [ebp], 0
	je process_input_break
	cmp byte ptr [ebp], 0
	je process_input_break
	add ebp, 2
	cmp byte ptr [ebp], 0
	jne process_input_loop
process_input_break:

	push edx // save total monkey count so edx can be used as scratch
	sub esp, 4

	cmp dword ptr [esp+8], 20
	je skip_part2_items

	mov dword ptr [esp], 0
part2_items_outer_loop:
	imul edi, [esp], MONKEY_SIZE
	add edi, offset monkey_array
	xor ebp, ebp
part2_items_items_loop:
	cmp ebp, [edi+24]
	je part2_items_items_break
	mov ebx, [edi+28+ebp*4]
	xor ecx, ecx
part2_items_inner_loop:
	imul esi, ecx, MONKEY_SIZE
	add esi, offset monkey_array
	mov esi, [esi+8]
	mov eax, ebx
	xor edx, edx
	idiv esi
	lea esi, [edi+156+ebp*8]
	mov [esi+ecx], dl
// inner loop break check
	inc ecx
	cmp ecx, [esp+4]
	jne part2_items_inner_loop
	inc ebp
	jmp part2_items_items_loop
part2_items_items_break:
	inc dword ptr [esp]
	mov eax, [esp+4]
	cmp [esp], eax
	jne part2_items_outer_loop

skip_part2_items:

	xor ebp, ebp // outer loop (round) counter. base pointer? I barely know her!
simul_outer_loop:
//mov eax, ebp
//call debug
	mov dword ptr [esp], 0 // inner loop (monkey) counter
simul_inner_loop:
	imul edi, [esp], MONKEY_SIZE
	add edi, offset monkey_array // current monkey pointer
	xor ecx, ecx // item loop counter
simul_item_loop:
	cmp ecx, [edi+24]
	je simul_item_break
	cmp dword ptr [esp+8], 20
	jne simul_do_part2
	mov eax, [edi+28+ecx*4]
	cmp dword ptr [edi], 1
	je p1_imm_mul
	js p1_imm_add
	imul eax, eax
	jmp p1_op_done
p1_imm_mul:
	imul eax, [edi+4]
	jmp p1_op_done
p1_imm_add:
	add eax, [edi+4]
p1_op_done:
	xor edx, edx
	mov ebx, 3
	idiv ebx
	mov ebx, eax // save real worry value
	xor edx, edx
	idiv dword ptr [edi+8]
	cmp edx, 0
	je p1_divisible
	mov eax, [edi+16]
	jmp p1_div_test_done
p1_divisible:
	mov eax, [edi+12]
p1_div_test_done:
	imul eax, MONKEY_SIZE
	add eax, offset monkey_array
	mov edx, [eax+24]
	mov [eax+28+edx*4], ebx
	inc dword ptr [eax+24]
	jmp simul_item_loop_inc
simul_do_part2:
	push ebp
	xor ebp, ebp
simul_innermost_loop:
	lea esi, [edi+156+ecx*8]
	movzx eax, byte ptr [esi+ebp]
	cmp dword ptr [edi], 1
	je p2_imm_mul
	js p2_imm_add
	imul eax, eax
	jmp p2_op_done
p2_imm_mul:
	imul eax, [edi+4]
	jmp p2_op_done
p2_imm_add:
	add eax, [edi+4]
p2_op_done:
	imul esi, ebp, MONKEY_SIZE
	add esi, offset monkey_array
	mov ebx, [esi+8]
	xor edx, edx
	idiv ebx
	lea esi, [edi+156+ecx*8]
	mov [esi+ebp], dl
	inc ebp
	cmp ebp, [esp+8]
	jne simul_innermost_loop
// innermost loop end
	mov eax, [esp+4]
	mov al, [esi+eax]
	cmp al, 0
	je p2_divisible
	mov eax, [edi+16]
	jmp p2_div_test_done
p2_divisible:
	mov eax, [edi+12]
p2_div_test_done:
	imul eax, MONKEY_SIZE
	add eax, offset monkey_array
	mov edx, [eax+24]
	mov ebx, [esi]
	mov [eax+156+edx*8], ebx
	mov ebx, [esi+4]
	mov [eax+156+edx*8+4], ebx
	inc dword ptr [eax+24]
	pop ebp
simul_item_loop_inc:
	inc ecx
	jmp simul_item_loop
simul_item_break:
	xor eax, eax
	mov [edi+24], eax
	add [edi+20], ecx
// check for inner loop break
	inc dword ptr [esp]
	mov eax, [esp+4]
	cmp dword ptr [esp], eax
	jne simul_inner_loop
// check for outer loop break
	inc ebp
	cmp ebp, [esp+8]
	jne simul_outer_loop

	mov edx, [esp+4]
	add esp, 8

	xor esi, esi // highest
	xor ecx, ecx // second highest
find_top_two_loop:
	dec edx
	cmp edx, 0
	js find_top_two_break
	imul edi, edx, MONKEY_SIZE
	add edi, offset monkey_array
	mov eax, [edi+20]
	cmp esi, eax
	js new_highest
	cmp ecx, eax
	jns find_top_two_loop
	mov ecx, eax
	jmp find_top_two_loop
new_highest:
	mov ecx, esi
	mov esi, eax
	jmp find_top_two_loop
find_top_two_break:

	cmp dword ptr [esp], 20
	jne part2

	imul ecx, esi
	push ecx
	push offset part1_string
	call printf
	add esp, 8

	mov dword ptr [esp], 10000
	jmp do_it_again

part2:
	//call debug

	add esp, 4

	mov eax, ecx
	mul esi
	push edx
	push eax
	push offset part2_string
	call printf
	add esp, 8

	pop ebp
	pop esi
	pop edi
	pop ebx
	xor eax, eax
	call exit

// String in ebp; advances ebp to first nonascii, returns number in eax, clobbers ebx
atoi:
	xor eax, eax
atoi_loop:
	movzx ebx, byte ptr [ebp]
	sub ebx, '0'
	js atoi_break
	cmp ebx, 10
	jns atoi_break
	imul eax, 10
	inc ebp
	add eax, ebx
	jmp atoi_loop
atoi_break:
	ret

// Advances ebp past first newline, clobbers al
skip_line:
	mov al, [ebp]
	inc ebp
	cmp al, '\n'
	jne skip_line
	ret

debug:
	push edx
	push ecx
	push eax
	call c_debug
	pop eax
	pop ecx
	pop edx
	ret

.section .rodata

hello_world_string:
	.ascii "i386? more like i<3legacybloat86 amirite\n\0"
args_wrong_string:
	.ascii "Usage: %s <AoC puzzle input>\n\0"
part1_string:
	.ascii "Part 1: %u\n\0"
part2_string:
	.ascii "Part 2: %llu\n\0" // big numbers!
//debug_string:
//	.ascii "Debug: %d\n\0"


.section .bss

.global monkey_array
monkey_array:
	.skip MAX_MONKEYS * MONKEY_SIZE

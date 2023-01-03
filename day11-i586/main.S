.intel_syntax noprefix

.section .text

#define MAX_ITEMS 16
//Layout of a monkey struct is
// 0:  operation type (0 for add literal, 1 for mul literal, 2 for old * old)
// 4:  literal operand, ignored for type 2
// 8:  test divisor
// 12: target if true
// 16: target if false
// 20: total number of items inspected
// 24: current number of items
// 28: array of items
#define MONKEY_SIZE (28 + (MAX_ITEMS * 4))

#define MAX_MONKEYS 8

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

	mov eax, esp

	push ebx
	push edi
	push esi
	push ebp

	mov ebp, 4[eax] // argv[1], the puzzle input. what's a base pointer? :p
	xor edx, edx // monkey counter

process_input_loop:
	imul edi, edx, MONKEY_SIZE
	add edi, offset monkey_array // current monkey pointer
	inc edx
	add ebp, 28 // skip "Monkey X:\n  Starting items: "
	xor ecx, ecx
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

	xor ebp, ebp // outer loop (round) counter. base pointer? I barely know her!
simul_outer_loop:
	xor esi, esi // inner loop (monkey) counter
simul_inner_loop:
	push edx // save total monkey count so edx can be used
	imul edi, esi, MONKEY_SIZE
	add edi, offset monkey_array // current monkey pointer
	xor ecx, ecx // item loop counter
simul_item_loop:
	cmp ecx, [edi+24]
	je simul_item_break
	mov eax, [edi+28+ecx*4]
	cmp dword ptr [edi], 1
	je imm_mul
	js imm_add
	imul eax, eax
	jmp op_done
imm_mul:
	imul eax, [edi+4]
	jmp op_done
imm_add:
	add eax, [edi+4]
op_done:
	xor edx, edx
	mov ebx, 3
	idiv ebx
	mov ebx, eax // save real worry value
	xor edx, edx
	idiv dword ptr [edi+8]
	cmp edx, 0
	je divisible
	mov eax, [edi+16]
	jmp div_test_done
divisible:
	mov eax, [edi+12]
div_test_done:
	imul eax, MONKEY_SIZE
	add eax, offset monkey_array
	mov edx, [eax+24]
	mov [eax+28+edx*4], ebx
	inc dword ptr [eax+24]
	inc ecx
	jmp simul_item_loop
simul_item_break:
	xor eax, eax
	mov [edi+24], eax
	add [edi+20], ecx
// check for inner loop break
	pop edx
	inc esi
	cmp esi, edx
	jne simul_inner_loop
// check for outer loop break
	inc ebp
	cmp ebp, 20
	jne simul_outer_loop

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

	imul ecx, esi
	push ecx
	push offset part1_string
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

/*debug:
	push edx
	push ecx
	push eax
	call c_debug
	pop eax
	pop ecx
	pop edx
	ret*/

.section .rodata

hello_world_string:
	.ascii "i386? more like i<3legacybloat86 amirite\n\0"
args_wrong_string:
	.ascii "Usage: %s <AoC puzzle input>\n\0"
part1_string:
	.ascii "Part 1: %u\n\0"
part2_string:
	.ascii "Part 2: %u\n\0"
//debug_string:
//	.ascii "Debug: %d\n\0"


.section .bss

.global monkey_array
monkey_array:
	.skip MAX_MONKEYS * MONKEY_SIZE

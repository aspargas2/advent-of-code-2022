#include "bytecode.h"

.section .text

@local variable allocations:
@ 0,1: return addresses
@ 2: input array reference
@ 3: output array reference
@ 4-9: temporary whatever
@ 10: debugging nonsense
@ 11: index into the input array for parsing the operations
@ 12-20: used in main for various purposes, preserved across calls
@ 21: index into output array
@ 22: used to track if we're doing part1 or part2
@ 0x3F: number of stacks (we actually have this many + 1, one is used to track movements)
@ 0x40: ints that are organized to form an array of bytes, starting with the lower 8 bits of int 0
@ the first n_stacks bytes are the current length of each stack, followed by 64-byte arrays for the stack data

@ solves AoC :D
.global solve_bytecode
solve_bytecode:
	@ We are passed two arrays in the stack: one for the input file and one for the output string.
	astore_2
	astore_3

	iconst_0
	istore 21
	iconst_0
	istore 22

reset_repeat:

	@ First, we need to figure out how many stacks there are
	@ There will be a newline after (4*(nstacks-1)) + 3 bytes from the input start, so look for that
	iconst_1
	istore 0x3F
	iconst_3
	istore 12
get_nstacks_loop:
	aload_2
	iload 12
	baload
	bipush '\n'
	isub
	ifeq get_nstacks_break
	iinc 0x3F, 1
	iinc 12, 4
	goto get_nstacks_loop
get_nstacks_break:

	@ 0 out lengths of all the stacks
	iconst_0
	istore 7
lengths_0_loop:
	iload 7
	iconst_0
	jsr local_var_array_store
	iinc 7, 1
	iload 0x3F
	iload 7
	isub
	ifne lengths_0_loop

	@ Next, find the bottom of the stacks in the input and so we can start pushing values from there
	@ There will be a double newline after the numbers under the stacks, so look for that then back up one line
	iload 12 @ Get the index of that first newline from earlier
	istore 7
	iinc 12, 1 @ Inc this so it's now the length of a line in the first part of the input
find_bottom_loop:
	iload 7
	iload 12
	iadd
	istore 7

	aload_2
	iload 7
	iconst_1
	iadd
	baload
	bipush '\n'
	isub
	ifne find_bottom_loop
	@ We now have the index of the first of the two newlines

	@ Calculate the index of the first number in the "move x from x to x" input section and save it for later
	iload 7
	bipush 7
	iadd
	istore 11

	@ Subtract appropriately so this value now points to the first actual letter of the bottom line of the stack data in the input
	iload 7
	iload 12
	iconst_1
	ishl
	isub
	iconst_2
	iadd
	istore 13

	@ Initialize the local stacks with the initial data from the input
read_init_data_outer_loop:
	iconst_0
	istore 20
read_init_data_inner_loop:
	aload_2
	iload 13
	baload
	istore 4
	iload 4
	bipush ' '
	if_icmpeq skip_push
	iload 20
	iload 4
	jsr local_stack_push
skip_push:
	iinc 13, 4
	iinc 20, 1
	iload 20
	iload 0x3F
	isub
	ifne read_init_data_inner_loop
//read_init_data_inner_break:
	iload 13
	iload 12
	iconst_1
	ishl
	isub
	istore 13
	iload 13
	ifgt read_init_data_outer_loop

	iload 22
	ifne do_part2_operations_outer_loop

do_part1_operations_outer_loop:
	jsr atoi
	istore 12 @ Number of items to move
	iinc 11, 6 @ Skip " from "
	jsr atoi
	iconst_1
	isub @ Convert to 0 indexed
	istore 13
	iinc 11, 4 @ Skip " to "
	jsr atoi
	iconst_1
	isub @ Convert to 0 indexed
	istore 14
do_part1_operations_inner_loop:
	iload 14
	iload 13
	jsr local_stack_pop
	jsr local_stack_push
	iinc 12, -1
	iload 12
	ifne do_part1_operations_inner_loop
//do_part1_operations_inner_break:
	iinc 11, 6 @ Skip "\nmove "
	iload 11
	aload_2
	arraylength
	if_icmplt do_part1_operations_outer_loop
	goto skip_part2

do_part2_operations_outer_loop:
	jsr atoi
	istore 12 @ Number of items to move
	iinc 11, 6 @ Skip " from "
	jsr atoi
	iconst_1
	isub @ Convert to 0 indexed
	istore 13
	iinc 11, 4 @ Skip " to "
	jsr atoi
	iconst_1
	isub @ Convert to 0 indexed
	istore 14
	iload 12
	istore 15
do_part2_operations_inner_loop_1:
	iload 0x3F
	iload 13
	jsr local_stack_pop
	jsr local_stack_push
	iinc 15, -1
	iload 15
	ifne do_part2_operations_inner_loop_1

	iload 12
	istore 15
do_part2_operations_inner_loop_2:
	iload 14
	iload 0x3F
	jsr local_stack_pop
	jsr local_stack_push
	iinc 15, -1
	iload 15
	ifne do_part2_operations_inner_loop_2

	iinc 11, 6 @ Skip "\nmove "
	iload 11
	aload_2
	arraylength
	if_icmplt do_part2_operations_outer_loop

skip_part2:

	@ Pop off the top of each stack and store those in the output buffer
	iconst_0
	istore 7
read_output_loop:
	iload 7
	jsr local_stack_pop
	istore 4
	aload_3
	iload 21
	iload 4
	bastore
	iinc 7, 1
	iinc 21, 1
	iload 7
	iload 0x3F
	if_icmpne read_output_loop

	iload 22
	ifne return_lab
	iinc 22, 1
	aload_3
	iload 21
	bipush ' '
	bastore
	iinc 21, 1
	goto reset_repeat @ Reread the entire input data into the stacks again for part 2

return_lab:
	aload_3
	iload 21
	iconst_0
	bastore

	ireturn

@ Takes index in local var 11, into array ref in local var 2, returns integer on the stack and updates local var to point to the first found non-decimal char
@ Clobbers: 0, 4, 5
atoi:
	istore_0 @ Store return address
	iconst_0
	istore 4
atoi_loop:
	aload_2
	iload 11
	baload
	istore 5
	iload 5
	bipush '0'
	if_icmplt atoi_break
	iload 5
	bipush '9'
	if_icmpgt atoi_break
	iload 4
	bipush 10
	imul
	iload 5
	bipush '0'
	isub
	iadd
	istore 4
	iinc 11, 1
	goto atoi_loop
atoi_break:
	iload 4
	ret 0

@ Takes index of stack and int value to store
@ Clobbers: 0, 1, 4, 5, 6, 7, 8, 9
local_stack_push:
	istore_0 @ Store return address
	istore 4 @ Store value to store
	istore 6 @ Store index

	iload 6
	jsr local_var_array_load @ Get current length of target stack
	istore 7

	iload 6
	bipush 6
	ishl @ Multiply index by 64
	iload 0x3F
	iconst_1
	iadd
	iadd @ Add number of stacks (advance past stack lengths)
	iload 7
	iadd @ Add current length of stack, we now have the index at which to store the new value
	
	iload 4
	jsr local_var_array_store @ Store it

	iload 6
	iinc 7, 1 @ Increment stack size
	iload 7
	jsr local_var_array_store

	ret 0


@ Takes index of stack, returns value popped
@ Clobbers: 0, 1, 4, 5, 6, 8, 9
local_stack_pop:
	istore_0 @ Store return address
	istore 6 @ Store index

	iload 6
	jsr local_var_array_load @ Get current length of target stack
	iconst_1
	isub @ Subtract 1 from it, so it is now the index in the stack of the item we want to pop, and the new length
	istore 4

	iload 6
	bipush 6
	ishl @ Multiply index by 64
	iload 0x3F
	iconst_1
	iadd
	iadd @ Add number of stacks (advance past stack lengths)
	iload 4
	iadd @ Add index of item to pop

	jsr local_var_array_load @ Get the value

	iload 6
	iload 4
	jsr local_var_array_store @ Store new stack size

	ret 0


@ Takes an index on the stack, uses a stupid hack to read the local variable index 0x40+(arg/4), then extracts the (arg%4)th byte from it and returns it on the stack
@ Clobbers: 1, 5, 8, 9
local_var_array_load:
	istore 8 @ Store return address
	istore 9 @ Store index
	iload 9
	iconst_2
	iushr
	iconst_2
	ishl @ Chop off the 2 lowest bits of the index (round down to multiple of 4)
	jsr stupid_load_next_instr @ Get the absolute address of the next instruction
stupid_load_next_instr:
	istore_1
	iload_1
	iadd @ Add rounded index passed
	istore 5 @ Store this in a local var
	iinc 1, (stupid_load_after_table - stupid_load_next_instr) @ Set up the address to return to from the table
	iinc 5, (stupid_load_table - stupid_load_next_instr) @ This value now points to the appropriate instruction in the table
	ret 5 @ Jump into the table
stupid_load_after_table:
	iload 9
	iconst_3
	iand @ Get index % 4
	iconst_3
	ishl @ Multiply by 8
	iushr @ Shift the value we loaded from the array to the right such that the target byte is now in the lowest 8 bits
	bipush -1
	bipush 24
	iushr
	iand @ Mask so we now have only this byte in an int
	ret 8 @ Return it

@ Same thing as previous func, but takes index and value to store
@ Clobbers: 1, 4, 5, 8, 9
local_var_array_store:
	istore 8 @ Store return address
	istore 4 @ Store value to store
	istore 9 @ Store index
	iload 9
	iconst_2
	iushr
	iconst_2
	ishl @ Chop off the 2 lowest bits of the index (round down to multiple of 4)
	jsr stupid_store_next_instr @ Get the absolute address of the next instruction
stupid_store_next_instr:
	istore_1
	iload_1
	iadd @ Add rounded index
	istore 5 @ Store this in a local var
	iinc 1, (stupid_store_after_table - stupid_store_next_instr) @ Set up the address to return to from the table
	iinc 5, (stupid_load_table - stupid_store_next_instr) @ This value now points to the appropriate instruction in the table
	ret 5 @ Jump into the load table
stupid_store_after_table:
	iload 9
	iconst_3
	iand @ Get index % 4
	iconst_3
	ishl @ Multiply by 8
	istore 9
	bipush -1
	bipush 24
	iushr
	iload 9
	ishl
	bipush -1
	ixor
	iand @ We have now masked out the byte we're trying to modify to 0
	iload 4
	iload 9
	ishl
	ior @ We now have the final int to write back to local storage

	iload 8
	istore_1
	iload 5
	bipush ((stupid_store_table - stupid_load_table) >> 4)
	iconst_4
	ishl
	iadd @ This just advances our old index into the load table to instead point into the store table. Didn't fit in signed 8 bits so couldn't use iinc
	istore 5
	ret 5 @ Jump into the store table, and return to the caller from there
	
@ Generates stupid tables of instructions. Args are inclusive.
.macro rept_with_ret instr, from, to
	\instr \from
	ret 1
	\instr \from+1
	ret 1
	\instr \from+2
	ret 1
	\instr \from+3
	ret 1
	.if \to-\from
	rept_with_ret \instr, "(\from+4)",\to
	.endif
	.endm

stupid_load_table:
	rept_with_ret iload, 0x40, 0xFC

stupid_store_table:
	rept_with_ret istore, 0x40, 0xFC
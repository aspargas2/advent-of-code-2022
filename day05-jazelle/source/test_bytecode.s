#include "bytecode.h"

.section .text

@ tests simple bytecode functionality and array loading
.global test_bytecode
test_bytecode:
	@ we are passed an array reference on the stack
	iconst_0
	@ load index 0 from it
	iaload
	@ add 5 to that value
	bipush 5
	iadd
	@ return it
	ireturn

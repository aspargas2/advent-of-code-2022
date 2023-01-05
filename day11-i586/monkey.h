#pragma once

#define MAX_ITEMS 32
#define MAX_MONKEYS 8

#define MONKEY_SIZE (28 + (MAX_ITEMS * (MAX_MONKEYS + 4)))

#ifndef __ASSEMBLER__
typedef struct monkey {
	uint32_t op_type;
	uint32_t operand;
	uint32_t divisor;
	uint32_t true_target;
	uint32_t false_target;
	uint32_t insp_total;
	uint32_t n_items;
	uint32_t items_part1[MAX_ITEMS];
	uint64_t items_part2[MAX_ITEMS];
} __attribute__((packed, aligned(4))) monkey;

_Static_assert(sizeof(monkey) == MONKEY_SIZE);
_Static_assert(sizeof(monkey) - sizeof(((monkey*)0)->items_part2) == 156);
#endif
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#include "monkey.h"

extern monkey monkey_array[MAX_MONKEYS];

_Static_assert(sizeof(monkey_array) == MAX_MONKEYS * MONKEY_SIZE);

void c_debug(uint32_t eax, uint32_t ecx, uint32_t edx) {
	printf("\nC debug called with eax %u, ecx %u, edx %u\n", eax, ecx, edx);
	bool die = false;
	for (int i = 0; i < 8; i++) {
		printf("Monkey %d: %u items, %u times, t: %u, u: %u\n", i, monkey_array[i].n_items, monkey_array[i].insp_total, monkey_array[i].true_target, monkey_array[i].false_target);
		if (monkey_array[i].n_items > 16)
			die = true;
		for (int j = 0; j < 16; j++) {
			printf("%016llX ", monkey_array[i].items_part2[j]);
		}
		printf("\n");
	}
	if (die)
		__builtin_trap();
}
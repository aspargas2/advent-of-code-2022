#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

extern struct {
	uint32_t op_type;
	uint32_t operand;
	uint32_t divisor;
	uint32_t true_target;
	uint32_t false_target;
	uint32_t insp_total;
	uint32_t n_items;
	uint32_t items[16];
} __attribute__((packed, aligned(4))) monkey_array[8];

_Static_assert(sizeof(monkey_array) == 8 * (28 + (16 * 4)));

void c_debug(uint32_t eax, uint32_t ecx, uint32_t edx) {
	printf("\nC debug called with eax %u, ecx %u, edx %u\n", eax, ecx, edx);
	bool die = false;
	for (int i = 0; i < 8; i++) {
		printf("Monkey %d: %u items, t: %u, u: %u\n", i, monkey_array[i].n_items, monkey_array[i].true_target, monkey_array[i].false_target);
		if (monkey_array[i].n_items > 16)
			die = true;
		for (int j = 0; j < 16; j++) {
			printf("%u ", monkey_array[i].items[j]);
		}
		printf("\n");
	}
	if (die)
		__builtin_trap();
}
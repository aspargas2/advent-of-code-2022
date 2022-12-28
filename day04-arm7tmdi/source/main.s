#define IRQ_VBLANK (1<<0)

.section .text

.global main
main:
	//; main never returns so we don't have to preserve anything
	bl irqInit
	mov r0, #IRQ_VBLANK
	bl irqEnable

	bl consoleDemoInit
	ldr r0, =reset_console_string
	bl iprintf

	ldr r0, =hello_world_string
	bl iprintf

	ldr r0, =input_file
	mov r10, #0
	mov r11, #0
main_loop:
	//add r11, #1
	ldrb r1, [r0]
	cmp r1, #0
	beq main_loop_break

	bl atoi_ish
	mov r5, r0
	mov r0, r1
	bl atoi_ish
	mov r6, r0
	mov r0, r1
	bl atoi_ish
	mov r7, r0
	mov r0, r1
	bl atoi_ish
	mov r8, r0
	mov r0, r1

	/*push {r0}
	ldr r0, =debug_string
	mov r1, r5
	mov r2, r6
	ldr r0, =input_file
	bl iprintf
	pop {r0}*/

	cmp r5, r8
	bhi main_p1_logic
	cmp r6, r7
	blo main_p1_logic
	add r11, #1

main_p1_logic:
	cmp r5, r7
	addeq r10, #1
	beq main_loop
	blo main_p1_lo
	cmp r6, r8
	addle r10, #1
	b main_loop
main_p1_lo:
	cmp r6, r8
	addge r10, #1
	b main_loop
main_loop_break:

	ldr r0, =part1_string
	mov r1, r10
	bl iprintf

	ldr r0, =part2_string
	mov r1, r11
	bl iprintf

wfi_die_loop:
	swi 5
	b wfi_die_loop

.ltorg

//; takes string in r0, returns number in r0 and end ptr + 1 in r1. stops on anything that's not a decimal number
atoi_ish:
	mov r1, r0
	mov r0, #0
	mov r2, #10
atoi_loop:
	ldrb r3, [r1], #1
	subs r3, #'0'
	cmp r3, #9
	bxhi lr
	mla r0, r2, r0, r3
	b atoi_loop

.section .rodata

reset_console_string:
	.ascii "\x1b[2J\0"
hello_world_string:
	.ascii "\x1b[10;10HHello World!\0"
part1_string:
	.ascii "\x1b[0;0HPart 1: %u\0"
part2_string:
	.ascii "\x1b[1;0HPart 2: %u\0"
/*debug_string:
	.ascii "\x1b[8;0H0x%X 0x%X 0x%X 0x%X\0"*/
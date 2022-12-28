#include "ti84pce.inc"

.assume ADL=1
.org userMem-2
.db tExtTok,tAsm84CeCmp


main:
	call _homeup
	call _ClrScrnFull
	
	; Save these at hardcoded locations so we can restore them no matter where the stack is
	ld (iy_save), IY
	ld (sp_save), SP

	;ld IX, test_string
	;ld A, 0
	;ld HL, 0
	;call atoi_acc
	;call disp_save_hl
	;push BC
	;pop HL
	;call disp_save_hl
	
	;ld DE, $4222
	;ld A, $6
	;call small_mul
	;push DE
	;pop HL
	;call disp_save_hl

	ld IX, input
main_outer_loop:
	ld HL, 0
main_inner_loop:
	ld A, '\n'
	call atoi_acc
	add IX, BC
	ld A, (IX)
	cp A, '\n'
	jp NZ, main_problem
	inc IX
	ld A, (IX)
	inc IX
	cp A, '\n'
	jr Z, main_inner_break
	cp A, 0
	jr Z, main_outer_break
	dec IX
	jr main_inner_loop
main_inner_break:
	;call disp_save_hl
	ld IY, top_three
	ld A, 3
main_top_three_loop:
	ld DE, (IY)
	push HL
	scf
	ccf
	sbc HL, DE
	pop HL
	jr C, main_not_highest
main_dethrone_loop:
	ld DE, (IY)
	ld (IY), HL
	ld BC, 3
	add IY, BC
	dec A
	jr Z, main_outer_loop
	push DE
	pop HL
	jr main_dethrone_loop
main_not_highest:
	ld BC, 3
	add IY, BC
	dec A
	jr NZ, main_top_three_loop
	jr main_outer_loop
main_outer_break:
	ld HL, part1_string
	call _PutS
	ld HL, (top_three)
	call disp_save_hl

	ld HL, part2_string
	call _PutS
	ld IY, top_three
	ld A, 3
	ld HL, 0
main_add_loop:
	ld DE, (IY)
	add HL, DE
	ld BC, 3
	add IY, BC
	dec A
	jr NZ, main_add_loop
	call disp_save_hl

main_end:
	ld IY, (iy_save)
	ld SP, (sp_save)
	call _GetKey
	call _ClrScrnFull
	res donePrgm, (IY+doneFlags)
	ret

main_problem:
	call disp_save_hl
	push DE
	pop HL
	call disp_save_hl
	ld HL, problem_string
	call _PutS
	jr main_end

problem_string:
	.db "Oopsie, something went wrong. Good luck figuring out why!",0
part1_string:
	.db "Part 1: ",0
part2_string:
	.db "          Part 2: ",0

iy_save:
	.long 0
sp_save:
	.long 0

top_three:
	.long 0
	.long 0
	.long 0

; TI is rather clobber-happy with this one (and also needs the original IY)
disp_save_hl:
	push AF
	push DE
	push HL
	push IY
	ld IY, (iy_save)
	call _DispHL
	pop IY
	pop HL
	pop DE
	pop AF
	ret


; Takes string terminated by value in A in IX, returns length in BC. IX points to terminator. Clobbers flags.
strlen:
	ld BC, 0

strlen_loop:
	cp A, (IX)
	ret Z
	inc BC
	inc IX
	jr strlen_loop


; Multiplies 24-bit number in DE with 8-bit number in A, returning result in DE. Clobbers A and flags.
small_mul:
	push HL
	ld HL, 0

small_mul_loop:
	tst A, $FF
	jr Z, small_mul_break
	add HL, DE
	dec A
	jr small_mul_loop

small_mul_break:
	push HL
	pop DE
	pop HL
	ret

; Takes string terminated by value in A in IX, adds number to HL and strlen in BC. Clobbers flags, IY, and A. UB if number does not fit in 24 bits or string contains non-decimal chars.
atoi_acc:
	push DE
	;ld HL, 0

	call strlen
	push BC
	ld IY, pow10s

atoi_loop:
	dec IX
	ld A, (IX)
	sub A, '0'
	ld DE, (IY)
	call small_mul
	add HL, DE
	jp C, main_problem ; Check for overflow
	ld DE, 3
	add IY, DE
	dec C ; Assuming strlen returned <256, which it would have to for the number to fit. Decrementing a reg pair doesn't update cond flags, wtf!
	jr NZ, atoi_loop

	pop BC
	pop DE
	ret

pow10s:
	.long 1
	.long 10
	.long 100
	.long 1000
	.long 10000
	.long 100000
	.long 1000000
	.long 10000000

;test_string:
;	.db "2703700",0

input:
#include "elf_calories_input.inc"
	.db 0
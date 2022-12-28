.section .text

.align 4
.global solve
solve:
  addi a1, a1, -16
  s32i a10, a1, 12
  s32i a9, a1, 8
  s32i a8, a1, 4
  s32i a0, a1, 0

  .literal inp, input_file
  .literal letters, present_letters
  l32r a3, inp
  l32r a7, letters
  movi a8, 0
  movi a9, 0
  movi a10, 0

main_loop:
  l8ui a2, a3, 0
  beqz a2, main_loop_break

  movi a4, 0
strlen_loop:
  beqi a2, '\n', strlen_break
  addi a4, a4, 1
  add a5, a4, a3
  l8ui a2, a5, 0
  j strlen_loop
strlen_break:

  srli a4, a4, 1
  movi a6, 0
first_half_loop:
  add a5, a3, a6
  l8ui a2, a5, 0
  call0 letter_to_index_a2
  add a5, a7, a2
  movi a2, 1
  s8i a2, a5, 0

  ssl a10
  movi a2, 1
  sll a2, a2
  l8ui a0, a5, 52
  or a0, a0, a2
  s8i a0, a5, 52

  addi a6, a6, 1
  bne a6, a4, first_half_loop

second_half_loop:
  add a5, a3, a6
  l8ui a2, a5, 0
  beqi a2, '\n', second_half_break
  call0 letter_to_index_a2
  add a5, a7, a2
  l8ui a0, a5, 0
  beqz a0, second_half_not_it
  movi a0, 0
  s8i a0, a5, 0
  addi a2, a2, 1
  add a8, a8, a2

second_half_not_it:
  ssl a10
  movi a2, 1
  sll a2, a2
  l8ui a0, a5, 52
  or a0, a0, a2
  s8i a0, a5, 52

  addi a6, a6, 1
  j second_half_loop
second_half_break:
  /*addi a2, a2, 1
  add a8, a8, a2*/

  add a3, a3, a4
  add a3, a3, a4
  addi a3, a3, 1

  movi a2, 0
  movi a4, 0
memset_loop:
  add a5, a7, a4
  s32i a2, a5, 0
  addi a4, a4, 4
  movi a0, 52
  bne a0, a4, memset_loop

  addi a10, a10, 1
  blti a10, 3, main_loop
  movi a10, 0
find_common_loop:
  add a5, a7, a10
  l8ui a2, a5, 52
  beqi a2, 0b111, find_common_break
  addi a10, a10, 1
  j find_common_loop
find_common_break:
  addi a10, a10, 1
  add a9, a9, a10
  movi a10, 0

  movi a2, 0
  movi a4, 0
memset2_loop:
  add a5, a7, a4
  s32i a2, a5, 52
  addi a4, a4, 4
  movi a0, 52
  bne a0, a4, memset2_loop

  j main_loop
main_loop_break:
  mov a3, a8
  mov a2, a9

main_done:
  l32i a10, a1, 12
  l32i a9, a1, 8
  l32i a8, a1, 4
  l32i a0, a1, 0
  addi a1, a1, 16
  ret

main_problem:
  movi a2, 999999
  j main_done

.align 4
letter_to_index_a2:
  bbsi a2, 5, lowercase
  addi a2, a2, (-('A') + 26)
  j letter_conv_done
lowercase:
  addi a2, a2, -('a')
letter_conv_done:
  ret

.section .bss

.align 4
present_letters:
.skip 52, 0

badge_flags:
.skip 52, 0

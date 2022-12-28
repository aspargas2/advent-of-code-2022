#pragma once

#ifndef __ASSEMBLER__
#error This file is only to be included from assembly source files
#endif

#define NO_ARGS(mnem, opcode) \
	.macro mnem; \
	.byte opcode; \
	.endm

#define ARG_1(mnem, opcode) \
	.macro mnem arg0; \
	.byte opcode, \arg0; \
	.endm

#define ARG_2(mnem, opcode) \
	.macro mnem arg0, arg1; \
	.byte opcode, \arg0, \arg1; \
	.endm

#define ARG_3(mnem, opcode) \
	.macro mnem arg0, arg1, arg2; \
	.byte opcode, \arg0, \arg1, \arg2; \
	.endm

#define ARG_4(mnem, opcode) \
	.macro mnem arg0, arg1, arg2, arg3; \
	.byte opcode, \arg0, \arg1, \arg2, \arg3; \
	.endm

#define ARG_LAB(mnem, opcode) \
	.macro mnem lab; \
	.byte opcode; \
	.byte (((\lab - . + 1) >> 8) & 0xFF); \
	.byte ((\lab - . + 2) & 0xFF); \
	/*// This check would be great to have but it errors with non-constant expression and I have no idea why
	.if ((((\lab - . + 2) >> 16) != (-1 >> 16)) && (((\lab - . + 2) >> 16) != 0)); \
		.err "Didn't fit"; \
	.endif;*/ \
	.endm

// https://en.wikipedia.org/wiki/List_of_Java_bytecode_instructions

NO_ARGS(iconst_m1, 0x02)
NO_ARGS(iconst_0,  0x03)
NO_ARGS(iconst_1,  0x04)
NO_ARGS(iconst_2,  0x05)
NO_ARGS(iconst_3,  0x06)
NO_ARGS(iconst_4,  0x07)
NO_ARGS(iconst_5,  0x08)
ARG_1(bipush, 0x10) @ byte gets sign extended

NO_ARGS(istore_0, 0x3B)
NO_ARGS(istore_1, 0x3C)
NO_ARGS(istore_2, 0x3D)
NO_ARGS(istore_3, 0x3E)
ARG_1(istore, 0x36)

NO_ARGS(astore_0, 0x4B)
NO_ARGS(astore_1, 0x4C)
NO_ARGS(astore_2, 0x4D)
NO_ARGS(astore_3, 0x4E)
ARG_1(astore, 0x3A)

NO_ARGS(iload_0, 0x1A)
NO_ARGS(iload_1, 0x1B)
NO_ARGS(iload_2, 0x1C)
NO_ARGS(iload_3, 0x1D)
ARG_1(iload, 0x15)

NO_ARGS(aload_0, 0x2A)
NO_ARGS(aload_1, 0x2B)
NO_ARGS(aload_2, 0x2C)
NO_ARGS(aload_3, 0x2D)
ARG_1(aload, 0x19)

NO_ARGS(iaload, 0x2E)
NO_ARGS(baload, 0x33)
NO_ARGS(iastore, 0x4F)
NO_ARGS(bastore, 0x54)

NO_ARGS(arraylength, 0xBE)

NO_ARGS(iadd, 0x60)
NO_ARGS(isub, 0x64)
NO_ARGS(imul, 0x68)
//NO_ARGS(idiv, 0x6C) // Not hardware-implemented
NO_ARGS(ishl, 0x78)
NO_ARGS(ishr, 0x7A)
NO_ARGS(iushr, 0x7C)
NO_ARGS(iand, 0x7E)
NO_ARGS(ior, 0x80)
NO_ARGS(ixor, 0x82)

ARG_2(iinc, 0x84)

ARG_LAB(ifeq, 0x99)
ARG_LAB(ifne, 0x9A)
ARG_LAB(iflt, 0x9B)
ARG_LAB(ifge, 0x9C)
ARG_LAB(ifgt, 0x9D)
ARG_LAB(ifle, 0x9E)
ARG_LAB(if_icmpeq, 0x9F)
ARG_LAB(if_icmpne, 0xA0)
ARG_LAB(if_icmplt, 0xA1)
ARG_LAB(if_icmpge, 0xA2)
ARG_LAB(if_icmpgt, 0xA3)
ARG_LAB(if_icmple, 0xA4)
ARG_LAB(goto, 0xA7)

ARG_LAB(jsr, 0xA8)
ARG_1(ret, 0xA9)

// This is the only not-hardware-implented instruction I'm using,
// and it's only used for the purpose of returning to ARM mode once we're all done
NO_ARGS(ireturn, 0xAC)
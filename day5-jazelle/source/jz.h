#pragma once

//#include <stdint.h>
//#include <stdbool.h>

s32 enable_jazelle_hardware(void);
//s32 get_thing(void);
s32 do_jazelle(void* workmem, const u8* bytecode, void* arr1, void* arr2);

extern u8 test_bytecode[];
extern u8 solve_bytecode[];
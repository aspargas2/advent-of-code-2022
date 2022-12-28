/*
	Hello World example made by Aurelio Mannara for libctru
	This code was modified for the last time on: 12/12/2014 21:00 UTC+1
*/

#include <3ds.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include "jz.h"

static void die_exit(bool die) {
	printf("\nPress start to exit\n");
	
	// Main loop
	while (aptMainLoop())
	{
		//Scan all the inputs. This should be done once for each frame
		hidScanInput();

		//hidKeysDown returns information about which buttons have been just pressed (and they weren't in the previous frame)
		u32 kDown = hidKeysDown();

		if (kDown & KEY_START) break; // break in order to return to hbmenu

		// Flush and swap framebuffers
		gfxFlushBuffers();
		gfxSwapBuffers();

		//Wait for VBlank
		gspWaitForVBlank();
	}

	gfxExit();
	if (die) svcExitProcess();
}

//u32 thing = 0;
extern const char input_file[];

int main(int argc, char **argv) {
	gfxInitDefault();
	consoleInit(GFX_TOP, NULL);
	printf("Hello World!\n");

	svcBackdoor(enable_jazelle_hardware);
	printf("jazelle hardware is on!\n");

	/*svcBackdoor(get_thing);
	printf("thing: 0x%lX\n", thing);*/

	void* input_buf = NULL;
	void* workmem = memalign(1024, 0x2000);
	if (!workmem) {
		printf("memalign ded\n");
		goto exit;
	}

	s32 arr[] = {1, 42};
	s32 ret = do_jazelle(workmem, test_bytecode, arr, NULL);
	printf("test bytecode gave: %ld\n", ret);
	if (ret != 47) {
		printf("something went wrong with the test bytecode\n");
		goto exit;
	}

	size_t len = strlen(input_file);
	input_buf = memalign(4, sizeof(u32) + len + 1);
	if (!input_buf) {
		printf("memalign died for %zu\n", len);
		goto exit;
	}
	*(u32*)input_buf = len + 1;
	memcpy(input_buf + 4, input_file, len + 1);
	char output_buf[30];
	*(u32*)output_buf = sizeof(output_buf) - sizeof(u32);
	ret = do_jazelle(workmem, solve_bytecode, input_buf, output_buf);
	printf("\nsolve bytecode returned: %ld\n\n", ret);
	printf("Output Buffer: %s\n", output_buf + sizeof(u32));

exit:
	if (workmem) free(workmem);
	if (input_buf) free(input_buf);
	die_exit(false);
	return 0;
}

#include <3ds.h>
#include <stdio.h>
#include <string.h>

#include "cdc_bin.h"

// set MSB to get Luma3DS mapping for all-access, strong order
vu16* const dspP = (vu16*)(0x1FF00000 | (1 << 31));
vu16* const dspD = (vu16*)(0x1FF40000 | (1 << 31));

extern const char input[];

int main() {
    gfxInitDefault();

    consoleInit(GFX_TOP, NULL);

    printf("Hello!\n");

	

	Result res = dspInit();
    printf("dspInit: %08lX\n", res);
	if (R_FAILED(res))
		goto end;
    bool loaded = false;
	res = DSP_LoadComponent(cdc_bin, cdc_bin_size, 0xFF, 0xFF, &loaded);
    printf("DSP_LoadComponent: %08lX\n", res);
	if (!loaded || R_FAILED(res)) {
		printf("Failed to load DSP binary\n");
		goto end;
	}

	strcpy((void*) (dspD + 0x1000), input);
	dspD[0] = 0xFFFF;
	printf("Waiting for the DSP to finish...\n\n");
	while (dspD[0] == 0xFFFF)
		svcSleepThread(10 * 1000 * 1000);

	printf("DSP says %s\n", (char*) (dspD + 1));
	printf("Part 1: %hu\n", dspD[0x10]);
	printf("Part 2: %hu\n", dspD[0x11]);
	//printf("input: %s\n", (char*) (dspD + 0x1000));

end:
	printf("\nPress start to exit\n");

    while (aptMainLoop()) {
        hidScanInput();

        u32 kDown = hidKeysDown();

        if (kDown & KEY_START)
            break;

        // Flush and swap framebuffers
        gfxFlushBuffers();
        gfxSwapBuffers();

        // Wait for VBlank
        gspWaitForVBlank();
    }

    dspExit();
    gfxExit();

    return 0;
}


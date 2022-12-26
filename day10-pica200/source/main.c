#include <3ds.h>
#include <citro3d.h>
#include <string.h>
#include <stdio.h>

#include "program_shbin.h"

#define CLEAR_COLOR 0x000000FF

#define DISPLAY_TRANSFER_FLAGS \
	(GX_TRANSFER_FLIP_VERT(0) | GX_TRANSFER_OUT_TILED(0) | GX_TRANSFER_RAW_COPY(0) | \
	GX_TRANSFER_IN_FORMAT(GX_TRANSFER_FMT_RGBA8) | GX_TRANSFER_OUT_FORMAT(GX_TRANSFER_FMT_RGB8) | \
	GX_TRANSFER_SCALING(GX_TRANSFER_SCALE_NO))

static DVLB_s* program_dvlb;
static shaderProgram_s program;
static int uLoc_projection, uLoc_input;
static C3D_Mtx projection;

static void sceneInit(void)
{
	program_dvlb = DVLB_ParseFile((u32*)program_shbin, program_shbin_size);
	shaderProgramInit(&program);
	shaderProgramSetVsh(&program, &program_dvlb->DVLE[0]);
	shaderProgramSetGsh(&program, &program_dvlb->DVLE[1], 4);
	C3D_BindProgram(&program);

	// Get the location of the uniforms
	uLoc_projection = shaderInstanceGetUniformLocation(program.geometryShader, "projection");
	uLoc_input = shaderInstanceGetUniformLocation(program.geometryShader, "input");

	// Configure attributes for use with the vertex shader
	// Attribute format and element count are ignored in immediate mode
	C3D_AttrInfo* attrInfo = C3D_GetAttrInfo();
	AttrInfo_Init(attrInfo);
	AttrInfo_AddLoader(attrInfo, 0, GPU_FLOAT, 3); // v0=position
	//AttrInfo_AddLoader(attrInfo, 1, GPU_FLOAT, 3); // v1=color

	// Compute the projection matrix
	Mtx_OrthoTilt(&projection, 0.0, 400.0, 0.0, 240.0, 0.0, 1.0, true);

	// Configure the first fragment shading substage to just pass through the vertex color
	// See https://www.opengl.org/sdk/docs/man2/xhtml/glTexEnv.xml for more insight
	C3D_TexEnv* env = C3D_GetTexEnv(0);
	C3D_TexEnvInit(env);
	C3D_TexEnvSrc(env, C3D_Both, GPU_PRIMARY_COLOR, 0, 0);
	C3D_TexEnvFunc(env, C3D_Both, GPU_REPLACE);
}

//static bool firstrun = true;

//#define POINT_TO_FB_OFF(x, y) (3 * (((x) * 240) + y))

extern const char input[];

static void runSolveShader(void)
{
	// Update the uniforms
	C3D_FVUnifMtx4x4(GPU_GEOMETRY_SHADER,   uLoc_projection, &projection);
	//C3D_BoolUnifSet (GPU_GEOMETRY_SHADER,   uLoc_onlyvert,   firstrun);
	//firstrun = false;

	C3D_FVec* inputArr = C3D_FVUnifWritePtr(GPU_GEOMETRY_SHADER, uLoc_input, 80);
	const char* inputPtr = input;
	for (size_t i = 0; i < 160; i++) {
		const size_t arrIdx = i >> 1;
		const size_t cIdx = (i & 1) << 1;

		if (*inputPtr == '\0') {
			inputArr[arrIdx].c[cIdx] = 0.0f;
			inputArr[arrIdx].c[cIdx + 1] = 0.0f;
			break;
		} else if (*inputPtr == 'n') {
			inputArr[arrIdx].c[cIdx] = 1.0f;
			inputArr[arrIdx].c[cIdx + 1] = 0.0f;
		} else if (*inputPtr == 'a') {
			inputArr[arrIdx].c[cIdx] = 2.0f;
			int val;
			if (sscanf(inputPtr, "addx %d\n", &val) != 1) {
				printf("sscanf ded\n");
				return;
			}
			inputArr[arrIdx].c[cIdx + 1] = (float) val;
		} else {
			printf("a problem, there is: %c\n", *inputPtr);
			return;
		}

		while (*(inputPtr++) != '\n');
	}

	C3D_ImmDrawBegin(GPU_GEOMETRY_PRIM);
		C3D_ImmSendAttrib(0.0f, 0.0f, 0.5f, 0.0f);
		C3D_ImmSendAttrib(400.0f, 0.0f, 0.5f, 0.0f);
		C3D_ImmSendAttrib(0.0f, 240.0f, 0.5f, 0.0f);
		C3D_ImmSendAttrib(400.0f, 240.0f, 0.5f, 0.0f);
	C3D_ImmDrawEnd();
}

static void sceneExit(void)
{
	// Free the shader program
	shaderProgramFree(&program);
	DVLB_Free(program_dvlb);
}

int main()
{
	// Initialize graphics
	gfxInitDefault();
	C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
	C3D_CullFace(GPU_CULL_NONE);

	// Initialize the render target
	C3D_RenderTarget* target = C3D_RenderTargetCreate(240, 400, GPU_RB_RGBA8, GPU_RB_DEPTH24_STENCIL8);
	C3D_RenderTargetSetOutput(target, GFX_TOP, GFX_LEFT, DISPLAY_TRANSFER_FLAGS);

	// Initialize the scene
	sceneInit();

	consoleInit(GFX_BOTTOM, NULL);
	printf("picaCHUUUU\n\n");

	vu8* fb = gfxGetFramebuffer(GFX_TOP, GFX_LEFT, NULL, NULL);

	C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
		C3D_RenderTargetClear(target, C3D_CLEAR_ALL, CLEAR_COLOR, 0);
		C3D_FrameDrawOn(target);
		runSolveShader();
	C3D_FrameEnd(0);


	svcSleepThread(20 * 1000 * 1000);
	//printf("value: %hhu %hhu %hhu\n", fb[2], fb[1], fb[0]);
	printf("Part 1: %d\n", (fb[0] << 16) | (fb[1] << 8) | fb[2]);

	// Main loop
	while (aptMainLoop()) {
		hidScanInput();

		// Respond to user input
		u32 kDown = hidKeysDown();
		if (kDown & KEY_START)
			break; // break in order to return to hbmenu
	}

	// Deinitialize the scene
	sceneExit();

	// Deinitialize graphics
	C3D_Fini();
	gfxExit();
	return 0;
}

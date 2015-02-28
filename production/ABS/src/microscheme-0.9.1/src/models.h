/*	microScheme Models Header File	*/

#ifndef _MODELS_H_GUARD
#define _MODELS_H_GUARD

typedef struct model_info { 
	char *name;

	char *STR_TARGET;
	char *STR_PROG;
	char *STR_BAUD;

	bool software_reset;

	char *specific_asm;
} model_info;

extern model_info models[];
extern int numModels;

#endif
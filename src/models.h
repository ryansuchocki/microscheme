/* ======================= Microscheme =======================
 * Definitions for specific hardware models
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#ifndef _MODELS_H_GUARD
#define _MODELS_H_GUARD

#include <stdbool.h>

typedef struct model_info
{
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
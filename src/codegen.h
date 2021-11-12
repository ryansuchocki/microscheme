/* ======================= Microscheme =======================
 * Code Generator
 * (C) 2014-2021 Ryan Suchocki, et al.
 * http://github.com/ryansuchocki/microscheme
 */

#ifndef _CODEGEN_H_GUARD
#define _CODEGEN_H_GUARD

#include "models.h"
#include "parser.h"

// Shared function declarations

extern void codegen_emit(AST_expr *expr, int parent_numArgs, FILE *outputFile);
extern void codegen_emitPreamble(FILE *outputFile /*, int numUsedGlobals*/);
extern void codegen_emitPostamble(FILE *outputFile);
extern void codegen_emitModelHeader(model_info theModel, FILE *outputFile);

#endif